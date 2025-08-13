setup() {
  load 'test_helper/common-setup.bash'
    _common_setup
  source transfer_to_drive.sh
  SOURCE_DIR=$(mktemp -d)
  TARGET_DIR=$(mktemp -d)
}
teardown() {
  if [ $(ls "$SOURCE_DIR" | wc -l) -gt 0 ]; then
    echo "files in SOURCE_DIR, removing them"
      rm -r "${SOURCE_DIR}"/*
      fi
      if [ $(ls "$TARGET_DIR" | wc -l) -gt 0 ]; then
        echo "files in TARGET_DIR, removing them"
          rm -r "${TARGET_DIR}"/*
          fi
}
teardown_file() {
    rm -r "$TARGET_DIR"
    rm -r "$SOURCE_DIR"
    echo "TEARDOWN FILE FUNCTION RAN"
}

@test "handle_dir_file_transfer skips directories that are empty" {
    run handle_dir_file_transfer "$SOURCE_DIR" "$TARGET_DIR"

    [[ $output =~ empty ]]
}
@test "handle_dir_file_transfer moves files to target dir, source dir is empty" {
    for i in {1..5}; do
      mktemp -p "$SOURCE_DIR"
    done
    echo "files in source: $(ls $SOURCE_DIR)"
    echo "files in target: $(ls $TARGET_DIR)"
    handle_dir_file_transfer "$SOURCE_DIR" "$TARGET_DIR"
    echo "files in source: $(ls $SOURCE_DIR)"
    echo "files in target: $(ls $TARGET_DIR)"

   test $(ls $TARGET_DIR | wc -l ) -eq 5 
   test $(ls $SOURCE_DIR | wc -l ) -eq 0 
}
