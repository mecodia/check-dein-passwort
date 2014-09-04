# Check Dein Passwort Mobile Apps

PhoneGap powered Android and iOS versions of Check Dein Passwort. Brunch is used to assemble the website. PhoneGap is
used to build the native projects.

Brunch assembles the data for the webview into the `www` folder. Phonegap will take this folder and produce an Android
or iOS project.

## General setup

    npm install -g phonegap
    brunch build --production
    

## Android

You will need the Android SDK at a version higher than 19. 

    phonegap build android
    
You will then have to merge `platform_files/android` into the generated `platforms/android` directory. To delete
cached files, delete the `ant-build` directory.


## iOS

You will need Xcode. The project is in the repo because it was changed a bit and fully generating it doesn't work properly.

### Quick Testing

    phonegap build ios
    phonegap run ios

### Deployment

You can open the `platforms/ios/Check Dein Passwort.xcodeproj` to build and submit updates to the App Store.