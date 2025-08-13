#!/opt/homebrew/bin/bash

handle_dir_file_transfer() {
  if test $(find "$1"/* | wc -l) -eq 0; then
    echo "directory: $1, is empty"
  else 
    echo "directory: $1, is NOT empty"
    mv "$1"/* "$2"
  fi
}
local genre_locations="~/Music/mp3_genres/"
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  for item in $genre_locations/*;do
    if [[ "$item" =~ ".sh" || "$item" =~ "test" || "$item" == "my_script" ]]; then
      continue
    fi
    handle_dir_file_transfer "$item" "$2"
  done
fi
