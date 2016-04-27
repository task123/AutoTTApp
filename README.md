# AutoTTApp
iOS app used to control a remote controlled car by tilting the iOS device.

## Purpose
This app was made as part of [this project](https://github.com/task123/AutoTT), and was used to control an remote controlled car with two cameras based on a raspberry pi. It controlled the car by tilting the phone and show a video stream from the car. The app is very suitable for controlling a device (Raspberry Pi is an excellent choice) over WiFi with the gyroscope in an iPhone (or other iOS devices) and to show video stream. Althought it work well for simple controlling of devices over WiFi it got the capability to support quite advanced projects (which was it intended purpose) without making any changes to the app. For tips on how to implement tings on the server-side in the device you are trying to control, look at [the project](https://github.com/task123/AutoTT).

## Use
This app is not uploaded to the App Store, but anyone is free to download the project, just compile it on xCode (requires a mac) and upload it to an iOS device. If anyone uploads it to the App Store, it would be nice to make the app free and post the name of the app here (preferably with a link) so other people simply can download it from the App Store. One should however swap the background picture of the main view and the app icon, as described in the 'Raspberry Pi Logo' paragraph.

## Capabilities/features
* Connect over WiFi with a tcp connection given a ip address and port number.
* Send data of the rotation of the iOS device (Ideal for controlling devices with gyroscope data from iPhone).
  * Can control the update speed of rotation data over the tcp connection.
  * Can adjust the sensitivity.
  * Can set the neutral tilting position. 
* Can show webpages. Ideal for sending video stream from a http server. ( (https://github.com/task123/AutoTT) show a way of doing it. )
  * Can easily switch the the video stream (webpage) on and off.
  * Can send messages over the tcp connection the change the video quality.
* Gives the opportunity to select from a list of modes sendt to the iOS device over the tcp connection. (It sends a message of which mode you selected to the devices you are trying to control.)
  * Can give extra infomation about each of the modes if it is sendt to you iOS device.
* Can show a list of paramerter indicating the status of the device you are trying to control. (temperatur, battery percentage, etc.)
* Can send messages to and from your device.
  * Message sendt to your iOS device will pop-up on your screen (unless you are in the message window).
* It has two transparrent buttons on the left and right side of the main view
  * These can be turn on and off
  * They give information of then the buttons are pressed and released
* Can send message at a specifed interval to check the connection with the device you are trying to control
* Can preform simple voice recognition using OpenEars.

## Voice recognition
[OpenEars](http://www.politepix.com/openears/) is used for the primitive voice recognition the app is capable of, as most people we found online recommended this. OpenEars is free and allowed to use , but not open source. It have 

## How to communicate with it
The app communicates over a tcp connection with text commands. (In addition to and seperate from the video stream (or webpage) it can receive over http). The general structure of these messages/commands is as follows; they start with the type of message followed by "#$#", then the message (or data) before it finishes with "%^%\r\n". Example: "Gyro#$#0.001238;1.234522;-2.209182%^%" One does not have to implement all this commands, only handle that they are sendt.

### Commands sendt from the app
* Gyro#$#"roll";"pitch";"yaw"%^%\r\n
* GyroStop#$#%^%\r\n
* MainView#$#entered%^%\r\n
* MainView#$#exited%^%\r\n
* Modes#$#%^%\r\n
* ChosenMode#$#"number of the mode selected with zero-based numbering"%^%\r\n
* InfoModes#$#%^%\r\n
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
* InfoModes#$#"list seperated with semicolon, ';', giving extra information about the modes"%^%\r\n
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
