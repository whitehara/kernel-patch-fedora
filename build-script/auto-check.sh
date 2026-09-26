#!/bin/bash
# Koji の新ビルド候補を検出し、専用 git worktree 内で kernel-mock.sh -t(パッチ適用テスト)を実行して
# 結果を results/autocheck/ に記録・通知する。定期実行(systemd user timer 等)用。
#
# 自動化の範囲はテストと通知まで。HISTORY.md 更新・commit・tag・push は行わない(リリースは人が判断する)。
# テスト対象はローカル main にコミット済みの内容(専用 worktree を main から作る)。メインのワーキングツリーと
# HEAD には一切触れない。
#
# 使い方: auto-check.sh [--dry-run] [--only NVR] [-H HISTORY.md] [--forget NVR]
#   --dry-run       排他・候補抽出・状態フィルタ・worktree 作成までを行い、対象を表示して終了(mock 起動なし、
#                   state.tsv / last-run.txt / 通知なし)
#   --only NVR      状態フィルタと Koji 問い合わせを行わず、指定 NVR だけをテストする
#   -H HISTORY.md   koji-candidates.sh に渡す HISTORY.md(テスト用)
#   --forget NVR    state.tsv に reset 行を追記して終了(未テスト扱いに戻す)
#
# 終了コード: 0=新規なし/全 passed  1=failed あり  2=koji-error/infra error
#            3=busy または延期  64=使い方の誤り
#
# 状態は results/autocheck/state.tsv(追記専用): <ISO8601>\t<NVR>\t<STATUS>\t<main の SHA>\t<RUNID>
# STATUS: testing / passed / failed / error / aborted / reset。NVR の現在状態はその NVR の最終行。
# 通知: last-run.txt(毎回上書き)。webhook は ~/.config/kernel-autocheck/env に DISCORD_WEBHOOK_URL が
# あるときだけ送る。
#
# kernel-mock.sh は NVR ごとに 1 回ずつ呼ぶ。SRPM ダウンロード失敗などは failed_tests.log に出ないため、
# NVR 単位で終了コードを見ないと passed と取り違えるため。

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
RESULTS="$REPO_ROOT/results"
AUTO="$RESULTS/autocheck"
STATE="$AUTO/state.tsv"
LAST_RUN="$AUTO/last-run.txt"
RUNS_DIR="$AUTO/runs"
LOCK_FILE="$AUTO/lock"
CNK_LOCK_FILE="$RESULTS/.check-new-kernel.lock"
WT="${XDG_CACHE_HOME:-$HOME/.cache}/kernel-patch-fedora-autocheck/wt"
ENV_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/kernel-autocheck/env"
NVR_RE='^[0-9]+\.[0-9]+\.[0-9]+-[0-9]+\.fc[0-9]+$'
KEEP_RUNS=30

usage() {
    sed -n '/^# 使い方/,/^# 状態は/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'
}

DRY_RUN=false
ONLY=""
FORGET=""
HISTORY_OVERRIDE=""
while [ $# -gt 0 ]; do
    case $1 in
        --dry-run) DRY_RUN=true ;;
        --only)    [ $# -ge 2 ] || { usage >&2; exit 64; }; ONLY=$2; shift ;;
        --forget)  [ $# -ge 2 ] || { usage >&2; exit 64; }; FORGET=$2; shift ;;
        -H)        [ $# -ge 2 ] || { usage >&2; exit 64; }; HISTORY_OVERRIDE=$2; shift ;;
        -h|--help) usage; exit 0 ;;
        *)         echo "unknown option: $1" >&2; usage >&2; exit 64 ;;
    esac
    shift
done
for v in "$ONLY" "$FORGET"; do
    if [ -n "$v" ] && ! [[ $v =~ $NVR_RE ]]; then
        echo "invalid NVR (expected like 7.2.7-100.fc43): $v" >&2
        exit 64
    fi
done
if [ -n "$HISTORY_OVERRIDE" ]; then
    HISTORY_OVERRIDE=$(realpath -e -- "$HISTORY_OVERRIDE") || { echo "HISTORY file not found" >&2; exit 64; }
fi
case $WT in
    */kernel-patch-fedora-autocheck/wt) ;;
    *) echo "refusing unexpected worktree path: $WT" >&2; exit 2 ;;
esac

RUNID=$(date +%Y%m%d-%H%M%S)
RUN_DIR="$RUNS_DIR/$RUNID"
RUN_LOG="$RUN_DIR/run.log"
TARGETS=()
ATTENTION=()
WAITING_RELEASE=()
WAITING_FIX=()
DEFERRED=()
declare -A RESULT
TEST_PID=""
TERMINATED=false
WT_CREATED=false
TESTING_STARTED=false
ABORT_MARKED=false

now_iso() { date +%Y-%m-%dT%H:%M:%S%z; }

state_append() {
    if ! { printf '%s\t%s\t%s\t%s\t%s\n' "$(now_iso)" "$1" "$2" "$MAIN_SHA" "$RUNID" >> "$STATE"; } 2>/dev/null; then
        echo "WARNING: cannot append to $STATE ($1 $2)" >&2
        return 1
    fi
}

# 出力: "<status>\t<sha>"(記録なしなら何も出さない)
state_last() {
    [ -f "$STATE" ] || return 0
    awk -F'\t' -v n="$1" '$2 == n { s = $3; h = $4 } END { if (s != "") print s "\t" h }' "$STATE"
}

# 最後の reset/passed/failed/error 行より後の aborted 行数
aborted_streak() {
    if [ ! -f "$STATE" ]; then echo 0; return; fi
    awk -F'\t' -v n="$1" '
        $2 == n {
            if ($3 == "reset" || $3 == "passed" || $3 == "failed" || $3 == "error") c = 0
            else if ($3 == "aborted") c++
        }
        END { print c + 0 }' "$STATE"
}

notify() {
    $DRY_RUN && return 0
    [ -r "$ENV_FILE" ] || return 0
    local url body
    url=$(. "$ENV_FILE" >/dev/null 2>&1; printf '%s' "${DISCORD_WEBHOOK_URL:-}")
    [ -n "$url" ] || return 0
    body=$(printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps({"content": sys.stdin.read()[:1900]}))') || return 0
    # URL は argv に出さない(ps で見えるため)
    if ! printf 'url = "%s"\n' "$url" \
         | curl -fsS -m 30 -K - -H 'Content-Type: application/json' -d "$body" >/dev/null 2>&1; then
        echo "WARNING: webhook POST failed" >&2
    fi
}

# write_last_run <結果> <次のアクション>
write_last_run() {
    $DRY_RUN && return 0
    local tmp="$LAST_RUN.tmp.$$" n
    {
        echo "日時: $(now_iso)"
        echo "RUNID: $RUNID"
        echo "結果: $1"
        echo "対象NVR: ${TARGETS[*]:-なし}"
        for n in "${TARGETS[@]}"; do
            [ -n "${RESULT[$n]}" ] && echo "  $n: ${RESULT[$n]}"
        done
        [ -d "$RUN_DIR" ] && echo "ログ: $RUN_DIR"
        echo "次のアクション: $2"
        [ ${#DEFERRED[@]} -gt 0 ] && echo "延期(mock 実行中): ${DEFERRED[*]}"
        [ ${#ATTENTION[@]} -gt 0 ] && echo "要確認(aborted 連続): ${ATTENTION[*]}"
        [ ${#WAITING_RELEASE[@]} -gt 0 ] && echo "リリース待ち(passed・HISTORY.md 未記載): ${WAITING_RELEASE[*]}"
        [ ${#WAITING_FIX[@]} -gt 0 ] && echo "修正待ち(failed・main 未更新): ${WAITING_FIX[*]}"
        true
    } > "$tmp"
    mv -f "$tmp" "$LAST_RUN" || echo "WARNING: cannot write $LAST_RUN" >&2
}

summary_text() {
    local n
    echo "[kernel-autocheck] $1"
    for n in "${TARGETS[@]}"; do
        [ -n "${RESULT[$n]}" ] && echo "  $n: ${RESULT[$n]}"
    done
    [ ${#DEFERRED[@]} -gt 0 ] && echo "延期(mock 実行中): ${DEFERRED[*]}"
    [ ${#ATTENTION[@]} -gt 0 ] && echo "要確認(aborted 連続): ${ATTENTION[*]}"
    return 0
}

# コマンドラインの先頭が kernel-mock.sh のものだけ(文字列を含むだけの別プロセスは除く)
manual_mock_running() {
    pgrep -f '^(/bin/bash |/usr/bin/bash |bash )?[^ ]*kernel-mock\.sh( |$)' >/dev/null
}

# root 所有の mock 本体は、ユーザー側の mock ラッパー(comm=mock)が TERM で死んだ後も数秒残る。
# コマンドライン先頭が「<...>/python3 -tt <...>/libexec/mock/mock 」のものだけ(文字列を含むだけの別プロセスは除く)
mock_backend_running() {
    pgrep -f '^[^ ]*/python3 -tt [^ ]*/libexec/mock/mock ' >/dev/null
}

is_busy() {
    manual_mock_running && return 0
    pgrep -x mock >/dev/null && return 0
    mock_backend_running && return 0
    return 1
}

# filter_targets <状態を書くか true|false>。入力: $CANDIDATES。出力: TARGETS ATTENTION WAITING_*
filter_targets() {
    local write=$1 nvr status sha streak
    TARGETS=(); ATTENTION=(); WAITING_RELEASE=(); WAITING_FIX=()
    while IFS= read -r nvr; do
        [ -n "$nvr" ] || continue
        if ! [[ $nvr =~ $NVR_RE ]]; then
            echo "WARNING: ignoring candidate with unexpected NVR format: $nvr" >&2
            continue
        fi
        IFS=$'\t' read -r status sha < <(state_last "$nvr")
        case $status in
            ""|reset|error)
                TARGETS+=("$nvr") ;;
            passed)
                WAITING_RELEASE+=("$nvr") ;;
            failed)
                if [ "$sha" = "$MAIN_SHA" ]; then WAITING_FIX+=("$nvr"); else TARGETS+=("$nvr"); fi ;;
            testing|aborted)
                streak=$(aborted_streak "$nvr")
                if [ "$status" = testing ]; then
                    streak=$((streak + 1))
                    $write && state_append "$nvr" aborted
                fi
                if [ "$streak" -ge 2 ]; then ATTENTION+=("$nvr"); else TARGETS+=("$nvr"); fi ;;
        esac
    done <<< "$CANDIDATES"
}

setup_worktree() {
    mkdir -p "$(dirname "$WT")" || return 1
    if [ -e "$WT" ] || git -C "$REPO_ROOT" worktree list --porcelain | grep -qxF "worktree $WT"; then
        git -C "$REPO_ROOT" worktree remove --force "$WT" >/dev/null 2>&1 || rm -rf -- "$WT"
    fi
    git -C "$REPO_ROOT" worktree prune
    local err
    err=$(git -C "$REPO_ROOT" worktree add --detach "$WT" main 2>&1) || { echo "$err" >&2; return 1; }
    WT_CREATED=true
}

remove_worktree() {
    $WT_CREATED || return 0
    git -C "$REPO_ROOT" worktree remove --force "$WT" >/dev/null 2>&1 || rm -rf -- "$WT"
    git -C "$REPO_ROOT" worktree prune
    WT_CREATED=false
}

on_signal() {
    if [ -n "$TEST_PID" ] && kill -0 "$TEST_PID" 2>/dev/null; then
        TERMINATED=true
        kill -TERM -- "-$TEST_PID" 2>/dev/null
    else
        exit 143
    fi
}

cleanup() {
    local rc=$? n last
    trap - EXIT
    if ! $DRY_RUN && $TESTING_STARTED; then
        for n in "${TARGETS[@]}"; do
            last=$(state_last "$n" | cut -f1)
            if [ "$last" = testing ]; then
                state_append "$n" aborted
                RESULT[$n]=aborted
                ABORT_MARKED=true
            fi
        done
        if $ABORT_MARKED; then
            write_last_run "中断" "自動テストが中断された(aborted)。次回の自動実行で再試行される。mock のプロセスが残っていれば終了を待つ"
            notify "$(summary_text '中断(aborted)')"
        fi
    fi
    remove_worktree
    if ! $DRY_RUN && [ -d "$RUNS_DIR" ]; then
        ls -1 "$RUNS_DIR" | sort | head -n "-$KEEP_RUNS" | while IFS= read -r d; do
            [ -n "$d" ] && rm -rf -- "${RUNS_DIR:?}/$d"
        done
    fi
    exit $rc
}

# run_one <NVR>: RESULT[<NVR>] に passed / failed / error を入れる
run_one() {
    local nvr=$1 rc failed=false
    printf '%s\n#EOF\n' "$nvr" > "$WT/build-script/support-vers"
    mkdir -p "$WT/results"
    rm -f "$WT/results/failed_tests.log"
    # 状態を記録できないままテスト(数時間)を回すと、毎回再テストしてしまう
    if ! state_append "$nvr" testing; then
        RESULT[$nvr]=error
        echo "=== $(now_iso) skip $nvr: cannot record state ===" >> "$RUN_LOG"
        return 0
    fi
    echo "=== $(now_iso) start $nvr ===" >> "$RUN_LOG"

    # 出力は run.log にだけ残す(全量を journal に流さない)
    setsid -w bash -c 'cd "$1/build-script" || exit 1
                       set -o pipefail
                       nice -n 19 ionice -c3 ./kernel-mock.sh -t 2>&1 | tee -a "$2" >/dev/null' _ "$WT" "$RUN_LOG" &
    TEST_PID=$!
    wait "$TEST_PID"
    rc=$?
    if $TERMINATED; then
        wait "$TEST_PID" 2>/dev/null
        TEST_PID=""
        return 0
    fi
    TEST_PID=""

    if [ -s "$WT/results/failed_tests.log" ]; then
        cat "$WT/results/failed_tests.log" >> "$RUN_DIR/failed_tests.log"
        awk '{ print $1 }' "$WT/results/failed_tests.log" | grep -qFx "$nvr" && failed=true
    fi
    if $failed; then
        RESULT[$nvr]=failed
    elif [ "$rc" -eq 0 ]; then
        RESULT[$nvr]=passed
    else
        RESULT[$nvr]=error
    fi
    state_append "$nvr" "${RESULT[$nvr]}" || echo "WARNING: result of $nvr (${RESULT[$nvr]}) was not recorded; it will be retested" >&2
    rm -f "$WT/results/kernel-"*.src.rpm
    echo "=== $(now_iso) end $nvr: ${RESULT[$nvr]} (rc=$rc) ===" >> "$RUN_LOG"
}

# ---- main ----
mkdir -p "$AUTO" "$RUNS_DIR" || { echo "cannot create $AUTO" >&2; exit 2; }
MAIN_SHA=$(git -C "$REPO_ROOT" rev-parse --verify -q main) || { echo "branch 'main' not found" >&2; exit 2; }

if [ -n "$FORGET" ]; then
    state_append "$FORGET" reset || exit 2
    echo "reset: $FORGET"
    exit 0
fi

exec 8>"$LOCK_FILE"
if ! flock -n 8; then
    echo "busy: another auto-check is running (lock: $LOCK_FILE)"
    exit 3
fi
exec 9>"$CNK_LOCK_FILE"
if ! flock -n 9; then
    echo "busy: check-new-kernel.sh is running (lock: $CNK_LOCK_FILE)"
    exit 3
fi

if ! { : >> "$STATE"; } 2>/dev/null; then
    echo "infra-error: cannot write $STATE" >&2
    exit 2
fi

trap cleanup EXIT
trap on_signal TERM INT HUP

BUSY=false
is_busy && BUSY=true

if [ -n "$ONLY" ]; then
    CANDIDATES=$ONLY
else
    KC_ARGS=()
    [ -n "$HISTORY_OVERRIDE" ] && KC_ARGS=(-H "$HISTORY_OVERRIDE")
    KC_OUT=$("$SCRIPT_DIR/koji-candidates.sh" "${KC_ARGS[@]}")
    KC_RC=$?
    if [ "$KC_RC" -ne 0 ]; then
        if [ "$KC_RC" -eq 2 ]; then KIND=koji-error; else KIND="infra-error(koji-candidates.sh rc=$KC_RC)"; fi
        write_last_run "$KIND" "Koji 取得失敗。次回の自動実行で再試行される。続く場合は koji の疎通を確認"
        notify "$(summary_text "$KIND")"
        echo "$KIND"
        exit 2
    fi
    CANDIDATES=$(grep '^CANDIDATE: ' <<<"$KC_OUT" | sed 's/^CANDIDATE: //')
fi

if [ -n "$ONLY" ]; then
    TARGETS=("$ONLY")
else
    WRITE=true
    { $DRY_RUN || $BUSY; } && WRITE=false
    filter_targets $WRITE
fi

busy_exit() {
    if [ ${#TARGETS[@]} -gt 0 ]; then
        write_last_run "延期" "手動の kernel-mock.sh / mock が実行中のため延期。終了後の次回自動実行でテストされる"
        notify "$(summary_text '延期(mock 実行中)')"
    fi
    echo "busy: kernel-mock.sh / mock is running (targets: ${TARGETS[*]:-none})"
    exit 3
}

$BUSY && busy_exit

if [ ${#TARGETS[@]} -eq 0 ]; then
    write_last_run "新規なし" "対応不要"
    [ ${#ATTENTION[@]} -gt 0 ] && notify "$(summary_text '要確認(aborted 連続)')"
    echo "新規なし"
    [ ${#ATTENTION[@]} -gt 0 ] && echo "要確認(aborted 連続): ${ATTENTION[*]}"
    [ ${#WAITING_RELEASE[@]} -gt 0 ] && echo "リリース待ち(passed・HISTORY.md 未記載): ${WAITING_RELEASE[*]}"
    [ ${#WAITING_FIX[@]} -gt 0 ] && echo "修正待ち(failed・main 未更新): ${WAITING_FIX[*]}"
    exit 0
fi

# koji 問い合わせ(最大 15 分)の間に手動の mock が始まっていないか再確認する
is_busy && busy_exit

if ! setup_worktree; then
    write_last_run "infra-error" "worktree 作成に失敗($WT)。git worktree prune 後に再実行"
    notify "$(summary_text 'infra-error(worktree 作成失敗)')"
    echo "infra-error: worktree setup failed"
    exit 2
fi

if $DRY_RUN; then
    printf '%s\n#EOF\n' "${TARGETS[0]}" > "$WT/build-script/support-vers"
    echo "[dry-run] main=$MAIN_SHA worktree=$WT"
    echo "[dry-run] テスト対象: ${TARGETS[*]}"
    echo "[dry-run] worktree の support-vers(NVR ごとに 1 件ずつ書き換えて実行。例: 1 件目):"
    sed 's/^/    /' "$WT/build-script/support-vers"
    [ ${#ATTENTION[@]} -gt 0 ] && echo "[dry-run] 要確認(aborted 連続): ${ATTENTION[*]}"
    exit 0
fi

mkdir -p "$RUN_DIR"
TESTING_STARTED=true
write_last_run "実行中" "テスト完了を待つ。進捗は ログ の run.log"
notify "$(summary_text 'テスト開始')"

for nvr in "${TARGETS[@]}"; do
    # NVR ごとのテストは数時間かかる。開始前に手動の kernel-mock.sh が始まっていないか再確認し、
    # 始まっていたら残りは状態を書かずに延期する(mock の chroot 名は全体で共有のため)。
    # 確認から起動までの隙(TOCTOU)は残る。
    if [ ${#DEFERRED[@]} -gt 0 ] || manual_mock_running; then
        DEFERRED+=("$nvr")
        continue
    fi
    run_one "$nvr"
    $TERMINATED && break
done

if $TERMINATED; then
    exit 143
fi

ANY_FAILED=false
ANY_ERROR=false
for n in "${TARGETS[@]}"; do
    case ${RESULT[$n]} in
        failed) ANY_FAILED=true ;;
        error)  ANY_ERROR=true ;;
    esac
done

if $ANY_FAILED; then
    OVERALL=failed
    ACTION="失敗 NVR は kernel-mock.sh -d で調査し、パッチ修正が必要(failed_tests.log 参照)。修正を main にコミットすると自動で再テストされる。mock やネットワークなど基盤が原因と分かった場合は build-script/auto-check.sh --forget <NVR> で未テスト扱いに戻す"
    EXIT_CODE=1
elif $ANY_ERROR; then
    OVERALL=error
    ACTION="SRPM ダウンロード失敗などのインフラ要因。次回の自動実行で再試行される(手動なら --only <NVR>)"
    EXIT_CODE=2
elif [ ${#DEFERRED[@]} -gt 0 ]; then
    OVERALL="一部延期"
    ACTION="手動の kernel-mock.sh が始まったため残りの NVR は延期。終了後の次回自動実行でテストされる"
    EXIT_CODE=3
else
    OVERALL=passed
    ACTION="全 NVR パッチ適用成功。ユーザー承認後に HISTORY.md 更新→commit→tag(kernel-release)でリリース可"
    EXIT_CODE=0
fi

write_last_run "$OVERALL" "$ACTION"
notify "$(summary_text "$OVERALL")"
summary_text "$OVERALL"
echo "次のアクション: $ACTION"
exit $EXIT_CODE
