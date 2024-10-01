#!/bin/bash

PROJECT_OLD_NAME=("template" "Template" "TEMPLATE")
PROJECT_NEW_NAME=("" "" "")

printf "Project name [snake_case]: "
read PROJECT_NEW_NAME[0]
printf "Project name [CamelCase]: "
read PROJECT_NEW_NAME[1]
printf "Project name [UPPERCASE]: "
read PROJECT_NEW_NAME[2]


project_sed_name() {
    sed -i "s/${PROJECT_OLD_NAME[0]}/${PROJECT_NEW_NAME[0]}/g" "${1}"
    sed -i "s/${PROJECT_OLD_NAME[1]}/${PROJECT_NEW_NAME[1]}/g" "${1}"
    sed -i "s/${PROJECT_OLD_NAME[2]}/${PROJECT_NEW_NAME[2]}/g" "${1}"
    
    # Fix symbols
    sed -i "s/${PROJECT_NEW_NAME[0]} \\$/template \\$/g" "${1}" # template keyword in Blueprints
    sed -i "s/gtk_widget_init_${PROJECT_NEW_NAME[0]}/gtk_widget_init_template/g" "${1}" # GTK function
    sed -i "s/gtk_widget_class_set_${PROJECT_NEW_NAME[0]}_from_resource/gtk_widget_class_set_template_from_resource/g" "${1}" # GTK function
}

PROJECT_OLD_ID="com.konstantintutsch.Template"
PROJECT_NEW_ID=""

printf "Project ID [com.konstantintutsch.Template]: "
read PROJECT_NEW_ID

project_sed_id() {
    sed -i "s/${PROJECT_OLD_ID}/${PROJECT_NEW_ID}/g" "${1}"
}

# Apply updates
for directory in "build-aux" "data" "po" "src"
do
    for file in $(find ${directory} -name "*${PROJECT_OLD_ID}*")
    do
        mv --verbose "${file}" "${file//$PROJECT_OLD_ID/$PROJECT_NEW_ID}"
    done

    for file in $(find ${directory} -type f)
    do
        project_sed_id "${file}"
        project_sed_name "${file}"
    done
done
# Left-over files
for file in "Justfile" "meson.build"
do
    project_sed_id "${file}"
    project_sed_name "${file}"
done

# Reset git
rm --recursive --verbose --interactive=never .git
git init

# Update files
vim data/${PROJECT_NEW_ID}.desktop.in.in
vim data/${ProJECT_NEW_ID}.metainfo.xml.in.in

# Reset translations
rm --verbose --interactive=never po/*.po po/*.pot po/LINGUAS
touch po/LINGUAS

meson setup build
cd build
meson compile ${PROJECT_NEW_ID}-pot
cd ..
