#!/bin/bash

#checking if imagemagick needs to be installed.
if [ $(dpkg-query -W -f='${Status}' imagemagick 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  brew install imagemagick;
fi

#creating the ResizedImages1x2x3x folder for the images to be located.
resizedFolder=ResizedImages1x2x3x
mkdir -p $resizedFolder

echo -n "Step (1/2): ⚠️ '"$resizedFolder"' folder has been created, move all images that you want to resize into the '"$resizedFolder"' folder and press [Enter] when you are ready to continue."
read $resizedFolder
cd $resizedFolder

echo "Step (2/2): Enter the Bundle Indetifier e.g.'"com.example"' that these images will be associated to, then Press [Enter] to begin."
read developerName

#loop through each file in the folder.
#checking only for "jpg, jpeg and png" file extensions to make use of.
#create a folder for each image name.
#convert the images, rename and place into their folders.
#create the Contents.json file.

if [ "$(ls -A )" ]; then
    for file in * != null; do
        fileExtension=$(echo $file |awk -F . '{if (NF>1) {print $NF}}')
        if [[($fileExtension == "jpg") || ($fileExtension == "jpeg") || ($fileExtension == "png")]]; then
            name=$(echo "$file" | cut -f 1 -d '.')
            mkdir -p $name

            size=`identify -format "%[fx:w]x%[fx:h]" $file`
            w=`echo $size | awk -F "x" '{ print $1 }'`
            h=`echo $size | awk -F "x" '{ print $2 }'`

            at3x=$(($w))
            at1x=$(($at3x / 3))
            at2x=$(($at1x * 2))

            H3x=$(($h))
            H1x=$(($H3x / 3))
            H2x=$(($H3x * 2))

            convert $file -resize $at3x "$name/$name@3x.jpg"
            size3=`identify -format "%[fx:w]x%[fx:h]" "$name/$name@3x.jpg"`
            convert $file -resize $at2x "$name/$name@2x.jpg"
            size2=`identify -format "%[fx:w]x%[fx:h]" "$name/$name@2x.jpg"`
            convert $file -resize $at1x "$name/$name@1x.jpg"
            size1=`identify -format "%[fx:w]x%[fx:h]" "$name/$name@1x.jpg"`

            echo "{
        "images": [
            {
                "filename": "$file",
                "idiom": "iphone",
                "size": "$size1",
                "scale": "1x",
            },
            {
                "filename": "$file",
                "idiom": "iphone",
                "size": "$size2",
                "scale": "2x",
            },
            {
                "filename": "$file",
                "idiom": "iphone",
                "size": "$size3",
                "scale": "3x",
            }
        ],
        "info": {
            "author": "$developerName",
            "version": 1
        }
    }" > $name/Contents.json
        fi
    done
    echo "✔️ Successfully resized images at @1x @2x @3x into the '"$resizedFolder"' folder."
else
    echo "❌ '"$resizedFolder"' folder is empty"
fi
