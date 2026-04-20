#!/usr/bin/env bash
set -euo pipefail

OLD_WD="$(pwd)"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

cd "$SCRIPT_DIR"

cleanup() {
    rm -r data
    cd "$OLD_WD"
}
trap cleanup EXIT

mkdir data
duckdb -f dsdgen.sql
moon run cmd/main ""
