#!/usr/bin/env bash
# Check: behaviour. The API server answers `no` to the cluster-wide questions
# for the build-runner service account.
set -uo pipefail

identity="system:serviceaccount:starfleet:build-runner"
fail=0

answer="$(kubectl auth can-i '*' '*' --as="$identity" 2>/dev/null || true)"
if [ "$answer" != "no" ]; then
  echo "FAIL: build-runner can still do everything ('*' on '*'): answer '$answer'"
  fail=1
fi

answer="$(kubectl auth can-i delete nodes --as="$identity" 2>/dev/null || true)"
if [ "$answer" != "no" ]; then
  echo "FAIL: build-runner can still delete nodes: answer '$answer'"
  fail=1
fi

answer="$(kubectl auth can-i get secrets --all-namespaces --as="$identity" 2>/dev/null || true)"
if [ "$answer" != "no" ]; then
  echo "FAIL: build-runner can still read Secrets in every namespace: answer '$answer'"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: build-runner has no cluster-wide power"
fi
exit "$fail"
