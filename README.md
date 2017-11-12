## QMLpass
QMLpass is a QML frontend for the standard unix password manager (https://www.passwordstore.org/).

This is an app build for the Sailfish operating system.

I am not aware of any other fronted for pass on SilfishOS, this is why I wrote it (because pass is great).

I am also neiter a Qt nor python dev.

The app is basically a QML frontend that calls the pass script and other hacks via python calls.
Some of it is pretty hacky and can be improved.
It works for me and was not tested fully on a vanilla Sailfish OS.
I developed it for SailfishOS 2.1.3.7 (Kymijoki).

### features
* search for passwords
* create initial gpg-agent config
* kill gpg-agent
* cache passphrases for GPG keys
* pull from git
* timeout on copy to clipboard

### features that may come
* add/delete passwords
* ~~sync to git~~ push to git
* edit gpg-agent config (e.g. adjust timeouts)
* ~~timeout on copy to clipboard~~

This shall be a simple fronted and not a swiss army knife to do all the pass/GPG stuff, so here are some...

### ... features that will most likelly never come:
* initial setup of pass --> best done on the commandline
* configure GPG keys --> best done on the commandline

### dependencies
You will need a recent gnupg version (tested with 2.2.1), because QMLpass makes use of the "--with-keygrip" parameters.

A recent version of gnupg and it's dependecies can be obtained here:

https://openrepos.net/content/yeoldegrove/gnupg-suite

or here

http://repo.merproject.org/obs/home:/yeoldegrove:/crypt/sailfish_latest_armv7hl/

### thanks

Many thanks to zx2c4, pass is great.

Many thanks to IJHack and QtPass, I use QtPass every day on the desktop ;)

The icon is inspired by the QtPass (https://github.com/IJHack/QtPass) icon and features the official QML and python logos.


## Comments and suggestions are welcome.
