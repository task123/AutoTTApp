# AutoTTApp
iOS app used to control a remote controlled car by tilting the iOS device.

## Purpose
This app was made as part of [this project](https://autottblog.wordpress.com), and was used to control an remote controlled and self driving car with two cameras based on a raspberry pi. It controlled the car by tilting the phone and show a video stream from the car. The app is very suitable for controlling a device (Raspberry Pi is an excellent choice) over WiFi with the gyroscope in an iPhone (or other iOS devices) and to show video stream. Althought it work well for simple controlling of devices over WiFi it got the capability to support quite advanced projects (which was it intended purpose) without making any changes to the app. For tips on how to implement tings on the server-side in the device you are trying to control, look at [the source code for the car in the project](https://github.com/task123/AutoTT).

## Download
This app is not uploaded to the App Store, but anyone is free to download the project, just compile it on Xcode (requires a mac) and upload it to an iOS device. The app is tested and works for Xcode 7.3 and iOS 9.3. (Remeber to change the iOS version when compiling it if you use another version.) As OpenEars is used for voice recognition, the OpenEars framework need to be installed to make the app work. Detajles of this is explained under the 'Voice Recognition' paragraph. If you do not wish to use voice recognition, the version of the app before the voice recognition was implemented is avalible under the 'beforeVoiceRecognition' branch. If anyone uploads it to the App Store, it would be nice to make the app free and post the name of the app here (preferably with a link) so other people simply can download it from the App Store. One should however swap the background picture of the main view and the app icon, as described in the 'Raspberry Pi Logo' paragraph. 

## Capabilities/features
* Connect over WiFi with a TCP connection given a ip address and port number.
* Send data of the rotation of the iOS device (Ideal for controlling devices with gyroscope data from iPhone).
  * Can control the update speed of rotation data over the tcp connection.
  * Can adjust the sensitivity.
  * Can set the neutral tilting position. 
* Can show webpages. Ideal for sending video stream from a http server. ( (https://github.com/task123/AutoTT) show a way of doing it. ) The default URL is the IP address used when initiating the TCP connection, and the same port pluss one ('IP address:port + 1).
  * Can easily switch the the video stream (webpage) on and off and change the video quality.
* Gives the opportunity to select from a list of modes sendt to the iOS device over the tcp connection. (It sends a message of which mode you selected to the devices you are trying to control.)
  * Can give extra infomation about each of the modes if it is sendt to you iOS device.
* Can show a list of paramerter indicating the status of the device you are trying to control. (temperatur, battery percentage, etc.)
* Can send text messages to and from your device.
  * Message sendt to your iOS device will pop-up on your screen (unless you are in the message window).
* It has two transparrent buttons on the left and right side of the main view
  * These can be turn on and off
  * They give information of then the buttons are pressed and released
* Can send message at a specifed interval to check the connection with the device you are trying to control
* Can preform simple voice recognition using OpenEars.

## Speech recognition
[OpenEars](http://www.politepix.com/openears/) is used for the primitive speech recognition the app is capable of, as most people we found online recommended this. OpenEars is free and allowed to upload to the AppStore, but not open source. (Even though the name would sugest otherwise.) The license for OpenEars only grant distribution of applications using OpenEars in binary form. The library and frameworks of OpenEars is therefor omitted. (We asked for permissing to share it as a whole, but OpenEars never replied.) The little code we have using OpenEars is left as it is, since it is more or less the same as the code from their nice [tutorial](http://www.politepix.com/openears/tutorial/) for 'Offline speech recognition'. This tutorial explains how to install and setup the library which is all you need to know to make the app work with full functionality. If you do not wish to use speech recognition, the version of the app before the speech recognition was implemented is avalible under the 'beforeVoiceRecognition' branch. There is also a small difference in how the 'InfoModes' command sendt to the app is used, so remember to use the branch's own 'README' file for referance.

### Voice commands
The app recognices the commands listed below. The word 'Car' must be clearly be separated from the next word for it to recognice the command. The voice commands can easiely by change by changing the array of NSStrings called 'words' on line 31 in VoiceRecognition.m in the folder autoTT/raspberryCar/. The NSString, @"CAR", on line 58 and 62 must also be changed to whatever you want to be the key word for recognising commands to be.
* CAR DRIVE
* CAR RIGHT
* CAR LEFT
* CAR STOP
* CAR HIGH (as in high beam, to turn the high beam on and off)

## How to communicate with it
The app communicates over a tcp connection with text commands. (In addition to and seperate from the video stream (or webpage) it can receive over http). The general structure of these messages/commands is as follows; they start with the type of message followed by "#$#", then the message (or data) before it finishes with "%^%\r\n". Example: "Gyro#$#0.001238;1.234522;-2.209182%^%" One does not have to implement all this commands, only handle that they are sendt.

### Commands sendt from the app
* Gyro#$#"roll";"pitch";"yaw"%^%\r\n
* GyroStop#$#%^%\r\n
* MainView#$#entered%^%\r\n
* MainView#$#exited%^%\r\n
* Modes#$#%^%\r\n
* ChosenMode#$#"number of the mode selected with zero-based numbering"%^%\r\n
* InfoModes#$#"number of the mode it wants information about with zero-based numbering%^%\r\n
* Status#$#%^%\r\n
* Stop#$#%^%\r\n
* Continue#$#%^%\r\n
* Disconnect#$#%^%\r\n
* ShutDown#$#%^%\r\n
* VideoStream#$#"On or 0ff"%^%\r\n
* VideoQuality#$#"High, Medium or Low"%^%\r\n
* LeftButtonTouchDown#$#%^%\r\n
* RightButtonTouchDown#$#%^%\r\n
* LeftButtonTouchUp#$#%^%\r\n
* RightButtonTouchUp#$#%^%\r\n
* ConnectionTest#$#%^%\r\n
* VoiceRecogniction#$#"keyword recogniced (see voice recognition)"%^%\r\n

### Commands sendt to the app
* Gyro#$#"number of seconds between each time gyroscopic data is sendt"%^%\r\n
* Message#$#"the message you wish to send"%^%\r\n
* Modes#$#"list of modes seperated with semicolon, ';'"%^%\r\n
* InfoModes#$#"information about the mode requested"%^%\r\n
* Status#$#"list seperated with semicolon, ';', giving infomation about the status of the device you wish to control (temp., battery percentage, etc.)"%^%\r\n
* VideoStreamRefresh#$#%^%\r\n
* VideoStreamStarted#$#%^%\r\n
* ButtonsOn#$#%^%\r\n
* ButtonsOff#$#%^%\r\n
* ConnectionTest#$#"number of seconds between each time the connection test message is sendt"%^%\r\n
* ConnectionTestStop#$#%^%\r\n
* VoiceRecognitionOn#$#%^%\r\n
* VoiceRecognitionOn#$#%^%\r\n

## Raspberry Pi Logo
This is not an official Raspberry Pi app, so the Raspberry Pi Logo should not be used as it is a register trademark. If one wish to use the logo, one should follow the rules provided by the Raspberry Pi Foundation [here](https://www.raspberrypi.org/trademark-rules/). We have however decided to use the logo for our private project, as we can not see any harm in this. We have used the logo as background on the main view and incorporaded in the app icon. If you wish to upload the app to the App Store, you should change this.

## Potential problems
* Not a problem for most projects, but it sometimes happens that some messages are lagging a little bit before several messages arrive at once. Did not present a problem in our project. The cause of this is unknown, and as it is only tested with the set-up form our project, the problem could potentially lie in our implementation of the python server it talked to.
* This is not a problem with the app, but a general problem it potentially could be nice to know about. If the device you wish to communicate with is behind a NAT-router, it could be hard to find out what the external port is unless you set up a static port for your device on your router.
