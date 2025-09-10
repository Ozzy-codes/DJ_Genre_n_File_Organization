#!/opt/homebrew/bin/bash

# first argument is the directory of which has the folders you want to extract files from e.g. the dirname which holds the name of genre directories with music files within them
local local_genre_locations="${1:-"~/Music/mp3_genres/"}"
# second argument is the directory of which has the folder you want to move files to e.g. the file_collection/mp3-files on an external drive that will house all music file memory nodes before creating hard links
local target_drive_path="${2:-"/Volumes/T7"}"

fail() {
    echo "Error: $1" >&2
    exit "${2:-1}" # Exit with specified code or 1 by default
}
handle_file_transfer() {
  local genre_dir_path="$1"
  local target_drive_path=$2
  genre_name="$(basename $genre_dir_path)"
  file_genre_name="${genre_name}.txt"
  date_string="$(date "+%b%d_%y_%a")"

  if test ! -d "$target_drive_path"/file_collection/mp3-files/${date_string}/${genre_name};then 
    mkdir -p "$target_drive_path"/file_collection/mp3-files/${date_string}/${genre_name}
  fi
  if test ! -d src/genre_file_list_names/${date_string}; then 
    mkdir -p src/genre_file_list_names/${date_string}
  fi

  if test -z "$(ls "$genre_dir_path"/*)";then
    echo "directory: $genre_dir_path, is empty"
  else 
    find "$genre_dir_path"/* -exec basename {} ";" >> src/genre_file_list_names/${date_string}/$file_genre_name 
    echo "moving files to storage"
    mv "$genre_dir_path"/* "$target_drive_path"/file_collection/mp3-files/${date_string}/${genre_name}
  fi
}
generate_hard_links() {
  local drive_base_path=$1
  local target_genre_dir=$2
  local genre_song_file=$3

  if test ! -d "$drive_base_path"/Djkit/"$target_genre_dir";then
    mkdir -p "$drive_base_path"/Djkit/"$target_genre_dir"
  fi
  while read -r line;do
    ln "$drive_base_path"/file_collection/mp3-files/"$line" "$drive_base_path"/Djkit/"$target_genre_dir"
  done < "$genre_song_file"
  echo "Moved to ${target_genre_dir}:"
  find "$drive_base_path"/Djkit/"$target_genre_dir" -maxdepth 0 -atime -1d
}
handle_dir_targeting() {
  local local_storage_path=$1
  local target_storage_path=$2

  for item in $local_storage_path/*;do
    if [[ "$item" =~ ".sh" || "$item" =~ "test" || "$item" == "my_script" ]]; then
      continue
    fi
    handle_file_transfer "$item" "${target_storage_path}"
    generate_hard_links "$target_storage_path" "$target_storage_path"/../../Djkit/"$item" "$file_name"
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if test "$target_drive_path" == "/Volumes/T7" && test ! -d /Volumes/T7; then
    fail "hard drive T7 is not connected" 2
  fi
  handle_dir_targeting $local_genre_locations "$target_drive_path"
fi
