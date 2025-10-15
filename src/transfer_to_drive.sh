#!/opt/homebrew/bin/bash

# first argument is the directory of which has the folders you want to extract files from e.g. the dirname which holds the name of genre directories with music files within them
local_genre_locations="${1:-"~/Music/mp3_genres/"}"
# second argument is the directory of which has the folder you want to move files to e.g. the file_collection/mp3-files on an external drive that will house all music file memory nodes before creating hard links
target_drive_path="${2:-"/Volumes/T7"}"
date_string="$(date "+%b%d_%y_%a")"

fail() {
    echo "Error: $1" >&2
    exit "${2:-1}" # Exit with specified code or 1 by default
}
handle_file_transfer() {
  local genre_dir_path="$1"
  local target_drive_path=$2
  local genre_name="$(basename $genre_dir_path)"
  local genre_file_name_path="src/genre_file_list_names/${genre_name}.txt"

  if test -z "$(ls "$genre_dir_path"/*)";then
    echo "directory: $genre_dir_path, is empty"
    return 
  fi

  if test ! -d "$target_drive_path"/file_collection/mp3-files/${date_string}/${genre_name};then 
    mkdir -p "$target_drive_path"/file_collection/mp3-files/${date_string}/${genre_name}
  fi
  # NOTE: target library is partitioned into date and genre based on incoming dir 
  if test ! -d src/genre_file_list_names; then 
    mkdir -p src/genre_file_list_names
  fi
  find "$genre_dir_path"/* -exec basename {} ";" >> $genre_file_name_path
  mv "$genre_dir_path"/* "$target_drive_path"/file_collection/mp3-files/${date_string}/${genre_name}
  echo "moved files to storage"
}
generate_hard_links() {
  local drive_base_path=$1
  local genre_name=$2
  local target_genre_dir="${drive_base_path}/Djkit/${genre_name}"
  local genre_file_name_path="src/genre_file_list_names/${genre_name}.txt"
  local source_genre_dir="${drive_base_path}/file_collection/mp3-files/${date_string}/${genre_name}"
  readarray -t music_file_link_targets < $genre_file_name_path

  if test ! -d $target_genre_dir;then
    mkdir -p $target_genre_dir
  fi
  if test ${#music_file_link_targets[@]} -gt 0;then
  echo "Number of songs to be linked into ${target_genre_dir}: ${#music_file_link_targets[@]}"
  echo "${music_file_link_targets[@]}"
  for file in "${music_file_link_targets[@]}";do
    ln ${source_genre_dir}/${file} $target_genre_dir
  done
  echo "Number of songs linked in the last 24hrs: $(find "$drive_base_path"/Djkit/"$genre_name" -maxdepth 0 -atime -1d | wc -l)"
  rm $genre_file_name_path
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if test "$target_drive_path" == "/Volumes/T7" && test ! -d /Volumes/T7; then
    fail "hard drive T7 is not connected" 2
  fi
  local local_storage_path=$local_genre_locations
  local target_storage_path=$target_drive_path

  for item in $local_storage_path/*;do
    if [[ "$item" =~ ".sh" || "$item" =~ "test" || "$item" == "my_script" ]]; then
      continue
    fi
    handle_file_transfer "$item" "${target_storage_path}"
    generate_hard_links "$target_storage_path" "$target_storage_path"/../../Djkit/"$item" "$file_name"
  done
fi
