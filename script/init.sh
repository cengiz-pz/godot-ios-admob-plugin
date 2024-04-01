#!/bin/bash
set -e


function display_help()
{
	echo
	./script/echocolor.sh -y "The " -Y "$0 script" -y " initializes the repository with the name of plugin."
	echo
	./script/echocolor.sh -Y "Syntax:"
	./script/echocolor.sh -y "	$0 [-h] <name of plugin>"
	echo
	./script/echocolor.sh -Y "Options:"
	./script/echocolor.sh -y "	h	display usage information"
	echo
	./script/echocolor.sh -Y "Examples:"
	./script/echocolor.sh -y "	   $> $0 'my_plugin'"
	echo
}


function display_status()
{
	echo
	./script/echocolor.sh -c "********************************************************************************"
	./script/echocolor.sh -c "* $1"
	./script/echocolor.sh -c "********************************************************************************"
	echo
}


function display_error()
{
	./script/echocolor.sh -r "$1"
}


if [ $# -eq 0 ]; then
  display_error "Error: Please provide the name of the plugin as an argument."
  echo
  display_help
  exit 1
fi

while getopts "h" option; do
	case $option in
		h)
			display_help
			exit;;
		\?)
			display_error "Error: invalid option"
			echo
			display_help
			exit;;
	esac
done

template_plugin_name="GodotPlugin"
template_plugin_name_snake_case="godot_plugin"
NEW_PLUGIN_NAME=$1
NEW_PLUGIN_NAME="${NEW_PLUGIN_NAME// /_}"	# replace spaces with underscore
NEW_PLUGIN_NAME="${NEW_PLUGIN_NAME//\-/_}"	# replace dashes with underscore
plugin_name_pascal_case=`echo $NEW_PLUGIN_NAME | perl -pe 's/(^|[_])./uc($&)/ge;s/[_]//g'`
plugin_name_snake_case=`echo $NEW_PLUGIN_NAME | perl -pe 's/([a-z0-9])([A-Z])/$1_\L$2/g' | perl -nE 'say lcfirst'`

display_status "Using \n*\t- '$NEW_PLUGIN_NAME' as plugin name, \n*\t- '$plugin_name_snake_case' for source files, \n*\t- '$plugin_name_pascal_case' for classes."

# Change value of `plugin_name` variable in the `script/build.sh` file to the plugin's new name.
sed -i '' -e "s/$template_plugin_name_snake_case/$NEW_PLUGIN_NAME/g" script/build.sh

# Change value of `plugin_name` variable in the `SConstruct` file to the plugin's new name.
sed -i '' -e "s/$template_plugin_name_snake_case/$NEW_PLUGIN_NAME/g" SConstruct

# Change value of `plugin_name` variable in the `Podfile` file to the plugin's new name.
sed -i '' -e "s/$template_plugin_name_snake_case/$NEW_PLUGIN_NAME/g" Podfile

# Change name of library archive mentioned in the plugin's `.gdip` file to the plugin's new name.
sed -i '' -e "s/name=\"$template_plugin_name\"/name=\"$NEW_PLUGIN_NAME\"/g" config/$template_plugin_name_snake_case.gdip
sed -i '' -e "s/$template_plugin_name_snake_case.release.a/$NEW_PLUGIN_NAME.release.a/g" config/$template_plugin_name_snake_case.gdip
sed -i '' -e "s/$template_plugin_name_snake_case/$plugin_name_snake_case/g" config/$template_plugin_name_snake_case.gdip

# Change to the plugin's new name in source files.
sed -i '' -e "s/$template_plugin_name_snake_case/$plugin_name_snake_case/g" $template_plugin_name_snake_case/*.h
sed -i '' -e "s/$template_plugin_name_snake_case/$plugin_name_snake_case/g" $template_plugin_name_snake_case/*.mm
sed -i '' -e "s/$template_plugin_name/$plugin_name_pascal_case/g" $template_plugin_name_snake_case/*.h
sed -i '' -e "s/$template_plugin_name/$plugin_name_pascal_case/g" $template_plugin_name_snake_case/*.mm

# Change location value in the plugin's `contents.xcworkspacedata` file to the plugin's new name.
sed -i '' -e "s/$template_plugin_name_snake_case.xcodeproj/$NEW_PLUGIN_NAME.xcodeproj/g" $template_plugin_name_snake_case.xcodeproj/project.xcworkspace/contents.xcworkspacedata

# Change to the plugin's new name in project.pbxproj file.
sed -i '' -e "s/$template_plugin_name_snake_case.h/$plugin_name_snake_case.h/g" $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/$template_plugin_name_snake_case.mm/$plugin_name_snake_case.mm/g" $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/${template_plugin_name_snake_case}_implementation.h/${plugin_name_snake_case}_implementation.h/g" $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/${template_plugin_name_snake_case}_implementation.mm/${plugin_name_snake_case}_implementation.mm/g" $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/$template_plugin_name_snake_case.a/$plugin_name_snake_case.a/g" $template_plugin_name_snake_case.xcodeproj/project.pbxproj
sed -i '' -e "s/$template_plugin_name_snake_case/$NEW_PLUGIN_NAME/g" $template_plugin_name_snake_case.xcodeproj/project.pbxproj

# Rename plugin source directory to the plugin's new name.
mv $template_plugin_name_snake_case $NEW_PLUGIN_NAME

# Rename plugin's `.gdip` file to the plugin's new name.
mv config/$template_plugin_name_snake_case.gdip config/$NEW_PLUGIN_NAME.gdip

# Rename plugin's xcodeproj file to the plugin's new name.
mv $template_plugin_name_snake_case.xcodeproj $NEW_PLUGIN_NAME.xcodeproj

# Rename source files.
mv $NEW_PLUGIN_NAME/$template_plugin_name_snake_case.h $NEW_PLUGIN_NAME/$plugin_name_snake_case.h
mv $NEW_PLUGIN_NAME/$template_plugin_name_snake_case.mm $NEW_PLUGIN_NAME/$plugin_name_snake_case.mm
mv $NEW_PLUGIN_NAME/${template_plugin_name_snake_case}_implementation.h $NEW_PLUGIN_NAME/${plugin_name_snake_case}_implementation.h
mv $NEW_PLUGIN_NAME/${template_plugin_name_snake_case}_implementation.mm $NEW_PLUGIN_NAME/${plugin_name_snake_case}_implementation.mm
