#!/usr/bin/env bash
# Pełny przebieg: baza (pgTAP), logika aplikacji (node:test), pipeline POI (unittest).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "== baza"
"$ROOT/tools/run_db_tests.sh"

echo "== aplikacja"
(cd "$ROOT/app" && npm test --silent)

echo "== pipeline POI"
(cd "$ROOT/tools" && python3 -m unittest -q test_seed_starowka)
