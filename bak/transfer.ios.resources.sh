
#!/bin/bash
#

source $CIOM_SCRIPT_HOME/ciom.util.sh

location="newdaxue"
appname="newdaxue"
src="$CIOM_VCA_HOME/v0/pre/ios/newdaxue/resource"
target="$CIOM_VCA_HOME/v0/pre/ios.ng/newdaxue/resource"
echo $src
echo $target
codes=$(ls $src)

for code in $codes; do
        mkdir -p $target/$code/
        #cp -r $src/$code/$location/newdaxue/Classes/Automation/* $target/$code/
        cp -r $src/$code/$location/$appname/Resources/Assets.xcassets/AppIcon.appiconset/Icon-60@2x.png $target/$code/AppIcon60x60@2x.png
        cp -r $src/$code/$location/$appname/Resources/Assets.xcassets/AppIcon.appiconset/Icon-60@3x.png $target/$code/AppIcon60x60@3x.png
        cp -r $src/$code/$location/$appname/Resources/Launch/en.lproj $target/$code/en.lproj
	cp -r $src/$code/$location/$appname/Resources/Launch/zh-Hans.lproj $target/$code/zh-Hans.lproj
	cp -r $src/$code/$location/$appname/Resources/Launch/zh-Hant-TW.lproj $target/$code/zh-Hant-TW.lproj
        #cp -r $src/$code/$location/Starfish/Images.xcassets/AppIcon.appiconset/Icon-60@3x.png $target/$code/AppIcon60x60@3x.png
        #cp -r $src/$code/$location/Starfish/Images.xcassets/LaunchImage.launchimage/Default@2x.png $target/$code/LaunchImage-700@2x.png
        #cp -r $src/$code/$location/Starfish/Images.xcassets/LaunchImage.launchimage/Default-568h@2x.png $target/$code/LaunchImage-700-568h@2x.png
        #cp -r $src/$code/$location/Starfish/Images.xcassets/LaunchImage.launchimage/Default-667h@2x.png $target/$code/LaunchImage-800-667h@2x.png
        #cp -r $src/$code/$location/Starfish/Images.xcassets/LaunchImage.launchimage/Default-736h@3x.png $target/$code/LaunchImage-800-Portrait-736h@3x.png
done


