set gd_script_files (fd --extension gd)
sd '^@onready' onready -- $gd_script_files \
    && sd '(\S)=(\S)' '$1 = $2' -- $gd_script_files \
    && gdformat --line-length 88 $gd_script_files
sd '^onready' '@onready' $gd_script_files
