#!/bin/bash
# Koji から未テストの kernel ビルド候補を洗い出す。テストは実行しない(Koji への問い合わせのみ)。
#
# 使い方: koji-candidates.sh [-H HISTORY.md のパス] [-S 系列ディレクトリの親]
# stdout: "CANDIDATE: <NVR>" / "EXCLUDE(stale, series max tested=X): <NVR>"
# 終了コード: 0=正常(候補の有無は問わない) / 1=引数・ローカル入力の問題 / 2=koji の失敗・タイムアウト・出力が空
#
# 系列内で HISTORY.md に記録済みの最大 X.Y.Z 未満のビルドは、その系列の旧実績(誤検出)として stale 扱いにする。
# koji list-builds の出力が古い順であることを前提に、fc ごとに末尾を最新とみなす。

set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
HISTORY="$SCRIPT_DIR/../HISTORY.md"
SERIES_ROOT="$SCRIPT_DIR/.."

while getopts "H:S:" opt; do
    case $opt in
        H) HISTORY=$OPTARG ;;
        S) SERIES_ROOT=$OPTARG ;;
        *) echo "Usage: $0 [-H HISTORY.md] [-S series_root]" >&2; exit 1 ;;
    esac
done

if [ ! -r "$HISTORY" ]; then
    echo "ERROR: cannot read HISTORY file: $HISTORY" >&2
    exit 1
fi
if [ ! -d "$SERIES_ROOT" ]; then
    echo "ERROR: series root is not a directory: $SERIES_ROOT" >&2
    exit 1
fi

ACTIVE_SERIES=$(for d in "$SERIES_ROOT"/[0-9]*.[0-9]*; do [ -d "$d" ] && basename "$d"; done | sort -V)
if [ -z "$ACTIVE_SERIES" ]; then
    echo "ERROR: no series directories ([0-9]*.[0-9]*) found under: $SERIES_ROOT" >&2
    exit 1
fi

TESTED_NVRS=$(grep '^kernel-' "$HISTORY" | sed 's/^kernel-//' | sort -u)
if [ -z "$TESTED_NVRS" ]; then
    echo "WARNING: no 'kernel-<NVR>' lines in $HISTORY; every latest build will be a CANDIDATE" >&2
fi

KOJI_OUT=$(timeout 900 koji list-builds --package=kernel --state=COMPLETE --quiet)
KOJI_RC=$?
if [ "$KOJI_RC" -ne 0 ] || [ -z "$KOJI_OUT" ]; then
    echo "ERROR: koji list-builds failed or returned no output (rc=$KOJI_RC)" >&2
    exit 2
fi
ALL_NVRS=$(echo "$KOJI_OUT" | awk '{print $1}')

for SERIES in $ACTIVE_SERIES; do
    PREFIX="kernel-${SERIES}."

    MAX_TESTED=$(echo "$TESTED_NVRS" | awk -v p="${SERIES}." 'index($0, p) == 1' \
                 | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+)-.*/\1/' | sort -V | tail -1)

    SERIES_BUILDS=$(echo "$ALL_NVRS" | awk -v p="$PREFIX" 'index($0, p) == 1' | grep -v '\.rc')
    [ -z "$SERIES_BUILDS" ] && continue

    for FC in fc42 fc43 fc44 fc45 fc46; do
        LATEST=$(echo "$SERIES_BUILDS" | grep "\.${FC}\$" | tail -n 1)
        [ -z "$LATEST" ] && continue
        NVR=${LATEST#kernel-}

        grep -qFx -- "$NVR" <<<"$TESTED_NVRS" && continue

        CAND_VER=$(echo "$NVR" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+)-.*/\1/')
        if [ -n "$MAX_TESTED" ]; then
            LOWER=$(printf '%s\n%s\n' "$MAX_TESTED" "$CAND_VER" | sort -V | head -1)
            if [ "$LOWER" = "$CAND_VER" ] && [ "$CAND_VER" != "$MAX_TESTED" ]; then
                echo "EXCLUDE(stale, series max tested=$MAX_TESTED): $NVR"
                continue
            fi
        fi
        echo "CANDIDATE: $NVR"
    done
done

exit 0
