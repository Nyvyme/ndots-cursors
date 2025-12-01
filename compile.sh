#!/usr/bin/env /bin/bash

theme_name="N-Dots"
theme_comment=""

path_theme_name="n_dots"
src_dir="src_svg"
builds_dir="build"
cursors_dir="cursors"

imgs_dir="imgs"

resolutions=(16 24 32 48 64 128)

hotspots=(8 12 16 24 32 64)

imgs=("arrow" "expand_all" "expand_lr" "expand_tb" "pointer")

# Check if inkscape is installed
if [ ! "$(which inkscape 2> /dev/null)" ]
then
  echo "inkscape must be installed to generate cursors"
  echo "Enter this command to install:"
  if has_command zypper; then
    echo "        sudo zypper in inkscape"
  elif has_command apt; then
    echo "        sudo apt install inkscape"
  elif has_command dnf; then
    echo "        sudo dnf install -y inkscape"
  elif has_command pacman; then
    echo "        sudo pacman -S inkscape"
  else
    echo "### Could not detect package manager!"
    echo "### Reference your distro's packages."
  fi
fi

# Check if xcursorgen is installed
if [ ! "$(which xcursorgen 2> /dev/null)" ]
then
  echo "xorg-xcursorgen must be installed to generate cursors"
  echo "Enter this command to install:"
  if has_command zypper; then
    echo "        sudo zypper in xorg-xcursorgen"
  elif has_command apt; then
    echo "        sudo apt install xorg-xcursorgen"
  elif has_command dnf; then
    echo "        sudo dnf install -y xorg-xcursorgen"
  elif has_command pacman; then
    echo "        sudo pacman -S xorg-xcursorgen"
  else
    echo "### Could not detect package manager!"
    echo "### Reference your distro's packages."
  fi
fi

# Create directory for images
if [ -n $imgs_dir ]
then
  mkdir -p $imgs_dir
fi

# Create directory for build
if [ -n $builds_dir ]
then
  mkdir -p $builds_dir
fi

# Create directory for cursors configs
if [ -n $cursors_dir ]
then
  mkdir -p $cursors_dir
fi

# Generate cursors
for ((res_i = 0; res_i < ${#resolutions[@]}; res_i++))
do
  resolution="${resolutions[$res_i]}"
  hotspot="${hotspots[$res_i]} ${hotspots[$res_i]}"

  theme_dir="$builds_dir/${path_theme_name}_${resolution}x${resolution}"
  build_dir="$theme_dir/cursors"
  cursor_dir="$cursors_dir/${resolution}x${resolution}"

  # Create source images directory
  if [ -n "$imgs_dir/${resolution}x${resolution}" ]
  then
    mkdir -p "$imgs_dir/${resolution}x${resolution}"
  fi

  # Create theme directory
  if [ -n $theme_dir ]
  then
    mkdir -p $theme_dir
  fi

  # Create build directory for specific resolution
  if [ -n $build_dir ]
  then
    mkdir -p $build_dir
  fi

  # Create cursors config directory for specific resolution
  if [ -n $cursor_dir ]
  then
    mkdir -p $cursor_dir
  fi

  # Create index.theme
  index_theme="[Icon Theme]\n"
  index_theme+="Name=${theme_name} ${resolution}x${resolution}\n"
  index_theme+="Comment=${theme_comment}\n"
  echo -e "$index_theme" > "$theme_dir/index.theme"

  for ((img_i = 0; img_i < ${#imgs[@]}; img_i++))
  do
    img=${imgs[$img_i]}
    output_image_path="$imgs_dir/${resolution}x${resolution}/$img.png"
    src_svg_path="$src_dir/$img.svg"
    src="$imgs_dir/${resolutions[$res_i]}x${resolutions[$res_i]}/${imgs[$img_i]}.png"
    cursor_file="$cursor_dir/${imgs[$img_i]}.cursor"
    build_file="$build_dir/${imgs[$img_i]}"

    # Generate images
    inkscape -o $output_image_path -w $resolution -h $resolution $src_svg_path

    # Generate config
    echo "$resolution $hotspot $src" > $cursor_file

    # Generate cursor
    xcursorgen $cursor_file $build_file
  done

  # Create symlinks
done

has_command() {
  "$1" -v $1 > /dev/null 2>&1
}
