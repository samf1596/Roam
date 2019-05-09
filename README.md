# Roum
Socializing Travel

This project was built to serve as a social media app for people enthusiastic about travel. It is a way to share experiences and include more in depth information about trips such as what to do and how to go about getting places.

It is a fully functioning app, although there may be bugs here and there. Feel free to report these bugs and ask questions.




### Instructions for running Roam
First, you must create a Firebase project and add the plist file to this project.
You all also need to enable Firebase Realtime Database, Firebase Storage, and Firebase Authentication.

For Authentication: Enable Email/Password, Anonymous

For Storage, set the rules as follows:
```
service firebase.storage {
	match /b/{bucket}/o {
		match /{allPaths=**} {
			allow read: if request.auth != null;
			allow write: if request.auth != null;
			}
		}
}
```

For Realtime Database, set the rules as follows:
```
{
  "rules": {        
	".read": "auth!=null",
	".write": "auth!=null"
	}
}
```

I am using Firebase which is installed via Pods, so to install the pods, cd into the project directory and run "pod install"
Then once the pods have installed, open the project by opening Roam.xcworkspace and build the Roam project as normal

NOTE: It may take a little while to properly index/build due to the thirdparty library "TLPhotoPicker" and it's dependencies, but it will build without error.

All buttons are operational at this time.

BUGS: If you run into any errors, closing and restarting the app will fix it most likely. The phone will vibrate and the image will go back to the default when it has uploaded.
