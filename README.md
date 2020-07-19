# Indie

A free and open (MIT Licensed) macOS system indicator applet for the menu bar.

Makes use of the excellent SMCKit library by [beltex](https://github.com/beltex/SMCKit), with
some modifications.

Clicking on the indie item in the status bar offers some options.

<img src="https://raw.githubusercontent.com/cbosoft/FanController/master/Screenshots/v1_default.png" width=400 />

You can change the properties shown by selecting predefined, or by defining your own. A property
is an SMC key which is measured, and a unit displayed alongside. Multiple SMC keys can be entered,
separated by commas, and the values are averaged together. This is useful for supplying multiple
measurements of a similar thing: like the temperature of the four cores of your CPU, or the
speeds of your two fans and so on.

<img src="https://raw.githubusercontent.com/cbosoft/FanController/master/Screenshots/v1_custom.png" width=400 />

Some properties are not available to the custom box: like Battery percentage which is calculated
from multiple other SMC keys.

# Installing

Clone this repository, open in Xcode, build. Built in Xcode 11, with Swift 5, under macOS 10.15
Catalina. I hope to get it in Homebrew, but not until I'm happy enough it would be useful!

# TODO
 - generate some predefined properties based on the capabilities of the system (number fans, 
   number processors etc)
 - see what other SMC key values might be of interest to show
