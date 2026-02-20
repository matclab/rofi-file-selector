#!/usr/bin/env bats

load bats-support/load
load bats-assert/load
load bats-mock/load


function setup() {
   mkdir -p "${BATS_TMPDIR:?/tmp}/$BATS_TEST_NAME"
   cd "$BATS_TMPDIR/$BATS_TEST_NAME" || \
      fail "unable to cd in $BATS_TMPDIR/BTNBATS_TEST_NAME"
   export CACHEDIR="/tmp/$BATS_TEST_NAME.cache"
}
function teardown() {
   [[ -d $CACHEDIR ]] && rm -rf "$CACHEDIR"
   [[ -d "${BATS_TMPDIR:?/tmp}/$BATS_TEST_NAME" ]] && \
      rm -rf "${BATS_TMPDIR:?/tmp}/$BATS_TEST_NAME"
}

SRC="$BATS_TEST_DIRNAME/.."

function default_config() {
   cat > /tmp/config.sh <<EOT
MENU=(home)
d_home=("$BATS_TMPDIR/$BATS_TEST_NAME")
EOT
}

@test 'check rofi status given as second args to chooseexe  ' {
# Catch issue #4

   default_config
   
   rofi="$(mock_create)"
   mock_set_status "${rofi}" 10
   mock_set_output "$rofi" "FILE1"

   chooseexe="$(mock_create)"

   touch a
   _CHOOSEEXE="$chooseexe" _ROFI="$rofi" CONFIG_DIR=/tmp \
      run "$SRC/rofi-file-selector.sh"
   assert_equal "$(mock_get_call_num "$rofi")"  "1"
   assert_equal "$(mock_get_call_num "$chooseexe")"  "1"
   assert_equal "$(mock_get_call_args "$chooseexe")"  "FILE1  10"
}


@test 'mimeapps is given whole path' {

   rofi="$(mock_create)"

   _ROFI="$rofi" run "$SRC/chooseexe.sh" DIR/NAME 10
   echo "$(mock_get_call_args "$rofi")"
   assert_line --partial "DIR/NAME"
}

@test 'mimeapps is given parent dir   ' {
# Catch issue #4
   rofi="$(mock_create)"
   mock_set_output "$rofi" ""

   _ROFI="$rofi" run "$SRC/chooseexe.sh" DIR/NAME 10
   run echo "$(mock_get_call_args "$rofi")"
   assert_line --partial "DIR"
   refute_line --partial "NAME" # No filename
}

@test 'chooseexe opens file with full path on default return' {
   rofi="$(mock_create)"

   _ROFI="$rofi" run "$SRC/chooseexe.sh" DIR/NAME 0
   run echo "$(mock_get_call_args "$rofi")"
   assert_line --partial "DIR/NAME"
}

@test 'chooseexe copies to clipboard on Ctrl+c' {
   xsel="$(mock_create)"

   _XSEL="$xsel" run "$SRC/chooseexe.sh" /some/file 11
   assert_success
   [[ "$(mock_get_call_num "$xsel")" -ge 1 ]]
}

@test 'chooseexe does nothing with less than 2 args' {
   rofi="$(mock_create)"

   _ROFI="$rofi" run "$SRC/chooseexe.sh" SINGLEARG
   assert_equal "$(mock_get_call_num "$rofi")" "0"
}

@test 'rofi-file-selector with multiple MENU items calls rofi for menu selection' {
   mkdir -p "$BATS_TMPDIR/$BATS_TEST_NAME/alpha_dir"
   mkdir -p "$BATS_TMPDIR/$BATS_TEST_NAME/beta_dir"
   touch "$BATS_TMPDIR/$BATS_TEST_NAME/alpha_dir/file1"

   config_dir="$BATS_TMPDIR/$BATS_TEST_NAME/config"
   mkdir -p "$config_dir"
   cat > "$config_dir/config.sh" <<EOT
MENU=(alpha beta)
d_alpha=("$BATS_TMPDIR/$BATS_TEST_NAME/alpha_dir")
d_beta=("$BATS_TMPDIR/$BATS_TEST_NAME/beta_dir")
EOT

   rofi="$(mock_create)"
   # First call: menu selection returns "alpha"
   mock_set_output "$rofi" "alpha"
   # Second call: file selection returns a file
   mock_set_output "$rofi" "file1" 2

   chooseexe="$(mock_create)"

   _CHOOSEEXE="$chooseexe" _ROFI="$rofi" CONFIG_DIR="$config_dir" \
      run "$SRC/rofi-file-selector.sh"
   assert_equal "$(mock_get_call_num "$rofi")" "2"
}

@test 'rofi-file-selector includes f_X files' {
   config_dir="$BATS_TMPDIR/$BATS_TEST_NAME/config"
   mkdir -p "$config_dir"
   cat > "$config_dir/config.sh" <<EOT
MENU=(test)
d_test=()
f_test=(/tmp/fileA /tmp/fileB)
EOT

   rofi="$(mock_create)"
   mock_set_output "$rofi" "/tmp/fileA"

   chooseexe="$(mock_create)"

   _CHOOSEEXE="$chooseexe" _ROFI="$rofi" CONFIG_DIR="$config_dir" \
      run "$SRC/rofi-file-selector.sh"
   assert_equal "$(mock_get_call_num "$chooseexe")" "1"
   [[ "$(mock_get_call_args "$chooseexe")" == *"/tmp/fileA"* ]]
}

