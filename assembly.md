Assembly
=====

### Introduction
The following steps will guide you through the process of building, programming and using a cheap and reliable pupillometry setup, as presented in [Names et al., (2019), etc. bla bla](link.to.pub).

### Background
Why is this useful. What lead us to pursue this? What's already out there?

### Bill Of Materials (BOM)
The following components are needed before starting the assembly process. Please be aware that we built and tested the setup with below linked components. However, many of these can probably be replaced with similar hardware. Also, the touch screen is not strictly required, as the Pi can also be controlled through another computer via an SSL connection. However, it makes the setup more user friendly and accessible.

#### Main Hardware
* [Raspberry Pi 3 B+](https://ch.rs-online.com/web/p/entwicklungskits-prozessor-mikrocontroller/1373331/)
* [Raspberry Pi Touchscreen (optional, but recommended)](https://ch.rs-online.com/web/p/entwicklungskits-grafikdisplay/8997466/)
* [Pi + Touchscreen housing (optional, but recommended)](https://ch.rs-online.com/web/p/raspberry-pi-gehause/9064665/)
* [Raspberry Pi NoIR Camera V2](https://ch.rs-online.com/web/p/videomodule/9132673/)
* [Pi Supply Bright Pi (or similar IR light source)](https://www.pi-shop.ch/pi-supply-bright-pi-bright-white-und-ir-kamera-licht-fuer-raspberry-pi)
* [Flex Cable ca. 1m](https://www.pi-shop.ch/raspberry-pi-camera-cable-50cm-100cm-200m)
* [2x Power Supply](https://ch.rs-online.com/web/p/ac-dc-adapter/1770223/)
* [SD Card (>= 16GB)](https://ch.rs-online.com/web/p/sd-karten/1249638/)
* [USB Stick (optional)](https://ch.rs-online.com/web/p/usb-sticks/8659155/)
* [USB Keyboard (optional)]()

#### Tools
* Screwdriver
* Soldering iron
* Play dough
* SD Card adapter
* Computer to flash SD card


Preparation
-----------

SD Card Setup
--------------

Assemble Touchscreen + Raspberry Pi
-----------------------------------

Assemble Light and Camera
-------------------------
Use one of Raspberry's NoIR cameras, because they come without an infrared filter. This is cruical to measure pupil diameter, as the iris reflects infrared light and therefore a maximal contrast between pupil and iris can be achieved.

Connect Pi and Camera
---------------------

Test it
-------
Run a test file that tells you if connections, etc. are working

Optional Add-Ons
----------------
Some intro why it might be helpful to add more. Highligh scalability of the system.

### Push Button Trigger

### TTL Trigger

### Connect Multiple Systems

### Network Storage
