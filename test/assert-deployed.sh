#!/usr/bin/env bash
# Asserts that the fixture stack was deployed from the expected commit and is serving.
# usage: assert-deployed.sh <deploy_path> <expected_sha> <compose_file> <container_id_out_file>
set -euo pipefail

deploy_path=$1 expected_sha=$2 compose_file=$3 cid_out=$4
fail() { echo "::error::$1"; exit 1; }

cd -- "$deploy_path"

actual_sha="$(git rev-parse HEAD)"
[[ "$actual_sha" == "$expected_sha" ]] || fail "deployed HEAD $actual_sha != expected $expected_sha"

cid="$(docker compose -f "$compose_file" ps -q --status running web)"
[[ -n "$cid" ]] || fail "web container is not running"

body=""
for _ in $(seq 1 30); do
  body="$(curl -fsS http://127.0.0.1:18080/ 2>/dev/null)" && break
  sleep 1
done
[[ "$body" == "ok" ]] || fail "web container did not serve the expected response (got: '$body')"

# The action must not leave key material behind in /tmp (its mktemp dir).
if grep -rlE 'BEGIN (OPENSSH|RSA|EC) PRIVATE KEY' /tmp 2>/dev/null | grep -q .; then
  fail "private key material left behind in /tmp"
fi

echo "$cid" > "$cid_out"
echo "OK: commit $actual_sha deployed, container ${cid:0:12} serving"
