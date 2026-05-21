# Tested Kernel NVR History

新しいものを上に追記。`check-new-kernel.sh` が未テスト NVR の判定に利用する。
日付はそのバージョン群のテストが通って commit / tag を打った日。

形式:
- `## YYYY-MM-DD (任意のメモ)` セクション
- セクション直下に `kernel-<NVR>` 形式で 1 行 1 NVR

判定ロジック:
- セクションのテキスト行(`##`/コメント/空行)以外、行頭 `kernel-` で始まる行を NVR とみなす。

## 2026-05-22
kernel-6.19.14-108.fc42
kernel-7.0.9-105.fc43
kernel-7.0.9-205.fc44

## 2026-05-20
kernel-6.19.14-107.fc42
kernel-7.0.9-104.fc43
kernel-7.0.9-204.fc44

## 2026-05-18
kernel-7.0.9-100.fc43
kernel-7.0.9-200.fc44

## 2026-05-16 (7.0.8 / 6.19.14-104.fc42)
kernel-7.0.8-200.fc44
kernel-7.0.8-100.fc43
kernel-6.19.14-104.fc42

## 2026-05-15 (7.0.7 / cjktty patch fix)
kernel-7.0.7-200.fc44
kernel-7.0.7-100.fc43
kernel-6.19.14-103.fc42

## 2026-05-14 (7.0.6 / handheld.patch fix)
kernel-7.0.6-200.fc44
kernel-7.0.6-100.fc43

## 2026-05-09 (7.0.4 / 6.19.14-101)
kernel-7.0.4-200.fc44
kernel-7.0.4-100.fc43
kernel-6.19.14-101.fc44
kernel-6.19.14-101.fc43
kernel-6.19.14-101.fc42

## 2026-05-01 (7.0.3)
kernel-7.0.3-200.fc44
kernel-7.0.3-200.fc43

## 2026-04-28 (7.0.2)
kernel-7.0.2-200.fc44
kernel-7.0.2-200.fc43

## 2026-04-27 (7.0.1)
kernel-7.0.1-200.fc44
kernel-7.0.1-200.fc43

## 2026-04-24 (6.19.14 initial)
kernel-6.19.14-300.fc44
kernel-6.19.14-200.fc43
kernel-6.19.14-100.fc42
