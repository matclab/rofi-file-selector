#!/usr/bin/env bats

load bats-support/load
load bats-assert/load
load test_helper

@test 'fd_cache first run is ok' {
  touch a ;touch  b ; touch c
  run "$SRC/fd_cache.sh" '.'  .
  assert_success
  output=$(echo "$output" | sed 's|^\./||')
  assert_output - <<-EOT
c
b
a
EOT
}

@test 'fd_cache order is updated' {
  touch a ;touch  b ; touch c
  run "$SRC/fd_cache.sh" '.'  .
  sleep 1
  touch a
  run "$SRC/fd_cache.sh" '.'  .
  assert_success
  output=$(echo "$output" | sed 's|^\./||')
  assert_output - <<-EOT
c
b
a
a
c
b
EOT
}

@test 'fd_cache new file taken into account' {
  touch a ;touch  b ; touch c
  run "$SRC/fd_cache.sh" '.'  .
  sleep 1
  touch x
  run "$SRC/fd_cache.sh" '.'  .
  assert_success
  output=$(echo "$output" | sed 's|^\./||')
  assert_output - <<-EOT
c
b
a
x
c
b
a
EOT
}

@test 'fd_cache different args use different caches' {
  touch a ; touch b
  run "$SRC/fd_cache.sh" 'a' .
  assert_success
  assert_line --partial "a"
  refute_line --partial "b"

  run "$SRC/fd_cache.sh" 'b' .
  assert_success
  assert_line --partial "b"
  refute_line --partial "a"
}

@test 'fd_cache full rebuild when cache older than one day' {
  touch a ; touch b ; touch c
  run "$SRC/fd_cache.sh" '.' .
  assert_success

  # Backdate cache to more than 1 day ago to trigger full rebuild
  CACHE="$CACHEDIR"/$(echo ". ." | md5sum | cut -f1 -d' ')
  echo "2000-01-01 00:00:00" > "$CACHE".date

  # Remove a file — full rebuild should exclude it
  rm c

  # Second run triggers background rebuild
  run "$SRC/fd_cache.sh" '.' .
  assert_success

  # Wait for background rebuild to complete
  sleep 1

  # Third run uses the rebuilt cache — deleted file should be gone
  run "$SRC/fd_cache.sh" '.' .
  assert_success
  output=$(echo "$output" | sed 's|^\./||')
  assert_line --partial "a"
  assert_line --partial "b"
  refute_line --partial "c"
}

@test 'fd_cache handles filenames with spaces' {
  touch "hello world" ; touch "foo bar" ; touch "normal"
  run "$SRC/fd_cache.sh" '.' .
  assert_success
  assert_line --partial "hello world"
  assert_line --partial "foo bar"
  assert_line --partial "normal"
}
