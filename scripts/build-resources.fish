function move_directory -a from -a to
    rip $to
    mkdir -p $to
    echo "Copying $from to $to"
    cp -r $from/* $to
end

function move_file -a from -a to -a file_name
    rip $to/$file_name
    mkdir -p $to
    echo "Copying $from to $to"
    cp -r $from/$file_name $to/$file_name
end

set project_root $HOME/Documents/godot/jackbox-test

# Download fonts
set fonts_folder $project_root/resources/fonts
mkdir -p $fonts_folder/ttf
mkdir -p $fonts_folder/woff
set font_zip_file_path $fonts_folder/heebo-font.zip
wget --output-document=$font_zip_file_path 'https://google-webfonts-helper.herokuapp.com/api/fonts/heebo?download=zip&subsets=latin&variants=800'

# Unzip fonts
unzip -o -j $font_zip_file_path heebo-v20-latin-800.ttf -d $project_root/resources/fonts/ttf
unzip -o -j $font_zip_file_path heebo-v20-latin-800.woff -d $project_root/resources/fonts/woff
unzip -o -j $font_zip_file_path heebo-v20-latin-800.woff2 -d $project_root/resources/fonts/woff2

# Move resources
move_directory $project_root/resources/textures $project_root/game/textures
move_directory $project_root/resources/textures $project_root/client/static/images
move_directory $project_root/resources/fonts/woff $project_root/client/static/fonts
move_directory $project_root/resources/fonts/woff2 $project_root/client/static/fonts
move_directory $project_root/resources/fonts/ttf $project_root/game/fonts
move_directory $project_root/client/build $project_root/server/static
move_file $project_root/resources/data $project_root/server/data characters.json
move_file $project_root/resources/data $project_root/server/data colours.json
move_file $project_root/resources/data $project_root/client/data characters.json
move_file $project_root/resources/data $project_root/client/data colours.json
move_file $project_root/resources/data $project_root/client/data menu_scene_ids.json
move_file $project_root/resources/data $project_root/game/data characters.json
move_file $project_root/resources/data $project_root/game/data colours.json
