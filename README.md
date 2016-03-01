# AutoTTApp
iOS app used to control a remote controlled car by tilting the iOS device.

## Purpose
This app was made as part of this project (https://github.com/task123/AutoTT), and was used to control an remote controlled car with two cameras based on a raspberry pi. It controlled the car by tilting the phone and show a video stream from the car. The app is very suitable for controlling a device (Raspberry Pi is an excellent choice) over WiFi with the gyroscope in an iPhone (or other iOS devices) and to show video stream. Althought it work well for simple controlling of devices over WiFi it got the capability to support quite advanced projects (which was it intended purpose) without making any changes to the app. For tips on how to implement tings on the server-side in the device you are trying to control, look at the project (https://github.com/task123/AutoTT).

## Use
This app is not uploaded to the App Store, but anyone is free to download the project,just compile it on xCode (requires a mac) and upload it to an iOS device. If anyone uploads it to the App Store, it would be nice to make the app free and post the name of the app here (preferably with a link) so other people simply can download it from the App Store.

## Capabilities/features
* Connect over WiFi with a tcp connection given a ip address and port number.
* Send data of the rotation of the iOS device (Ideal for controlling devices with gyroscope data from iPhone).
** Can control the update speed of rotation data over the tcp connection.
..* Can adjust the sensitivity.
..* Can set the neutral tilting position. 
* Can show webpages. Ideal for sending video stream from a http server. ( (https://github.com/task123/AutoTT) show a way of doing it. )
..* Can easily switch the the video stream (webpage) on and off.
..* Can send messages over the tcp connection the change the video quality.
* Gives the opportunity to select from a list of modes sendt to the iOS device over the tcp connection. (It sends a message of which mode you selected to the devices you are trying to control.)
..* Can give extra infomation about each of the modes if it is sendt to you iOS device.
* Can show a list of paramerter indicating the status of the device you are trying to control. (temperatur, battery percentage, etc.)
* Can send messages to and from your device.
..* Message sendt to your iOS device will pop-up on your screen (unless you are in the message window).
* It has two transparrent buttons on the left and right side of the main view
..* These can be turn on and off
..* They give information of then the buttons are pressed and released

## How to communicate with it
The app communicates over a tcp connection with text commands. (In addition to and seperate from the video stream (or webpage) it can receive over http). The general structure of these messages/commands is as follows; they start with the type of message followed by "#$#", then the message (or data) before it finishes with "%^%". Example: "Gyro#$#0.001238;1.234522;-2.209182%^%" 

### Commands sendt from the app
* Gyro#$#"roll";"pitch";"yaw"%^%
* Modes#$#%^%
* InfoModes#$#%^%
* Status#$#%^%
* Stop#$#%^%
* Continue#$#%^%
* Disconnect#$#%^%
* ShutDown#$#%^%
* VideoStream#$#"On or off"%^%
* VideoQuality#$#"High, Medium or Low"%^%
* LeftButtonTouchDownn#$#%^%
* RightButtonTouchDownn#$#%^%
* LeftButtonTouchUpn#$#%^%
* RightButtonTouchUpn#$#%^%

### Commands sendt to the app
* Gyro#$#"a number seconds between each time "Gyro#$#"roll";"pitch";"yaw"%^%" is sendt"%^%
* Message#$#"the message you wish to send"%^%
* Modes#$#"list of modes seperated with semicolon, ';'"%^%
* InfoModes#$#"list seperated with semicolon, ';', giving extra information about the modes"%^%
* Status#$#"list seperated with semicolon, ';', giving infomation about the status of the device you wish to control (temp., battery percentage, etc.)"%^%
* ButtonsOn#$#%^%
* ButtonsOff#$#%^%

## Potential problems
* Not a problem for most projects, but it sometimes happens that some messages are lagging a little bit before several messages arrive at once. Did not present a problem in our project. The cause of this is unknown, and as it is only tested with the set-up form our project, the problem could potentially lie in our implementation of the python server it talked to.
* This is not a problem with the app, but a general problem it potentially could be nice to know about. If the device you wish to communicate with is behind a NAT-router, it could be hard to find out what the external port is unless you set up a static port for your device on your router.
