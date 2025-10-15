setup() {
  load 'test_helper/common-setup.bash'
    _common_setup
  source transfer_to_drive.sh
  SOURCE_DIR=$(mktemp -d)
  TARGET_DIR=$(mktemp -d)
  date_string="$(date "+%b%d_%y_%a")"
  genre_name="$(basename "$SOURCE_DIR")"
    for i in {1..5}; do
      mktemp -p "$SOURCE_DIR"
    done
}
teardown() {
  project_path="$(echo "$(cd ${BATS_TEST_DIRNAME}/.. && pwd)")"
  if [ $(ls "$SOURCE_DIR" | wc -l) -gt 0 ]; then
    echo "files in SOURCE_DIR, removing them"
      rm -rf "${SOURCE_DIR}"/*
      fi
      if [ $(ls "$TARGET_DIR" | wc -l) -gt 0 ]; then
        echo "files in TARGET_DIR, removing them"
          rm -rf "${TARGET_DIR}"/*
          fi
      if [ $(find ${project_path}/src/genre_file_list_names -iname tmp* | wc -l) -gt 0 ]; then
        echo "tmp files in today's music history dir, removing them"
      find src/genre_file_list_names -iname tmp* -exec rm {} +
          fi
}
teardown_file() {
    rm -r "$TARGET_DIR"
    rm -r "$SOURCE_DIR"
    echo "TEARDOWN FILE FUNCTION RAN"
}

@test "HANDLE_FILE_TRANSFER: skips directories that are empty" {
  rm -r "${SOURCE_DIR}"/*
    run handle_file_transfer "$SOURCE_DIR" "$TARGET_DIR"

    echo "output: $output"
    [[ "${output,,}" =~ empty ]]
}
@test "HANDLE_FILE_TRANSFER: moves files to target dir, source dir is empty" {
    handle_file_transfer $SOURCE_DIR $TARGET_DIR

    test -d $TARGET_DIR/file_collection/mp3-files/${date_string}/${genre_name}
    test $(ls $TARGET_DIR/file_collection/mp3-files/${date_string}/${genre_name} | wc -l ) -eq 5 
    test $(ls $SOURCE_DIR | wc -l ) -eq 0 
}
@test "HANDLE_FILE_TRANSFER: generates file with incoming file names" {
    echo "files in source: $(ls $SOURCE_DIR)"
    echo "files in target: $(ls $TARGET_DIR)"
    handle_file_transfer "$SOURCE_DIR" "$TARGET_DIR"
    echo "files in source: $(ls $SOURCE_DIR)"
    echo "files in target/file_collection/mp3-files: $(ls $TARGET_DIR/file_collection/mp3-files/$date_string)"

    test -e src/genre_file_list_names/${genre_name}.txt
    grep "$(ls "$TARGET_DIR"/file_collection/mp3-files/${date_string}/${genre_name} | head -n 1)" src/genre_file_list_names/${genre_name}.txt
}
@test "GENERATE_HARD_LINKS: function exists" {
 declare -f generate_hard_links
}
@test "GENERATE_HARD_LINKS: test ln lands in the corect location" {
local genre="konpa"
local source_dir="${TARGET_DIR}/file_collection/mp3-files/${date_string}/${genre}"
if test ! -d $source_dir;then
mkdir -p $source_dir
fi
  for item in {1..3}; do
    touch ${source_dir}/"${genre}${item}.mp3"
echo "${genre}${item}.mp3" >> src/genre_file_list_names/${genre}.txt
      done

generate_hard_links $TARGET_DIR $genre 

test $(ls ${TARGET_DIR}/Djkit/${genre} | wc -l) -gt 1
readarray -t inode_number < ls -l ${TARGET_DIR}/Djkit/${genre} | awk '{print $2}' | tail -n +2
for i_number in "${inode_number[@]}";do
test i_number -gt 1
done
}
