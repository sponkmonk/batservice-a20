BATSERVICE FOR OR GALAXY A20

This is a software for the Galaxy A20, which conserves the battery between 45 and 50%, or which makes it possible to use a "power bank" such as this plug into the device's own battery, significantly prolonging the useful life of the device's internal battery.

Installed via Termux or Magisk¹, it works with practically any charger capable of delivering the power necessary to use the Galaxy A20, that is, any source with power greater than 5 W.


0. CANCELLATION OF WARRANTIES

This program comes with ABSOLUTELY NENHUMA GUARANTEE.
This is free software, and you can redistribute it under certain conditions; Read the COPYING file for details.

I tested just no model referred to. If your Android kernel does not have a specific load control file (see the "Bswitch" variable in the source code of this program), or your device is not rooted, or BatService will not work.


1. INSTALLING

  (a) Termux

With Termux installed via F-Droid, and with "Memory" permission, open and move this package to it. It may be necessary to install the 'unzip' command before extracting the package. For this:
    $ apt install unzip -y

Example:
    $ mkdir tmp && cd tmp
    $ mv /sdcard/Download/BatService-A20-Termux-v2.*.zip ./
    $ unzip BatService-A20-Termux-v2.*.zip
    $ chmod +x install.sh && ./install.sh
    $ su -c "echo Ok" # Make your root manager LEMBER of this permission

You need to install and run the Termux:Boot app at least once.

There is an unpackaged uninstall script, therefore I do not recommend turning it off.


  (b) Magisk

Use the script "module-create.sh" to create the Magisk installation package. That's it, just install the zip package.


2. HOW TO ENCLOSURE OR SERVICE (FOR UNWRAPPERS)

The service can be locked by creating a file named "exit.err" in the <module>/data directory.

Or it is recommended to simply disable the Magisk module and restart Android.


3. NOTIFICATIONS

BatService supports notifications through the Termux API. Simply install this extension following the official guide. As you might imagine: use the Termux version: F-Droid API! Next, install the necessary package.

Access wiki³ for details.


4. SETTINGS

The configuration file format to be saved in "$PREFIX/etc/batservice/config.txt" is simple like this example:
    charging-never-stop false
    charging-stop 50
    charging-continue 45
    service-delay-not-charging 60

Configuration is not mandatory*, but the file must end with an empty line if it has been handled manually.

There are restrictions for the supported values:
    cn: charging-never-stop | true, false
    cc:charging-continue | 15 <= cc < cs
    cs: charging-stop | cc < cs <= 100
    sd:service-delay-not-charging| 6 <= sd <= 60

(*) cc depends on cs, therefore it is not possible to insert just um!

NOTE: the abbreviations (cc, cs etc.) are only for ease of reading. The service does not interpret this!


ISSUES?

You should contact me on the Mastodon social network. I receive a lot of spam in my e-mail and may possibly ignore any foreign messages that you may have received.

Mastodon: @cledson_cavalcanti@mastodon.technology


[1] https://github.com/topjohnwu/Magisk
[2] https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries
[3] https://wiki.termux.com/wiki/Termux:API

by cleds.upper
