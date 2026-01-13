# Generic Lamp

## Overview
A BASH script for configuring a generic Linux LAMP stack. This should not be considered "Production Ready" by any means.

## Usage
### Arguments
* **help/Help**, Output script help message including acceptable arguments <br>
* **configure/Configure**, Configure generic LAMP stack. <br>
  Installs Apache, MariaDB and PHP. <br>
  Takes "DEB" or "RPM" as an argument. <br>
  Usage. `./generic-lamp.sh configure TYPE` <br>
  Ex. `./generic-lamp.sh configure DEB` <br>
  - **DEB Distro Examples:** <br>
    * *Debian*
    * *Ubuntu*
  - **RPM Distro Examples:** <br>
    * *Fedora*
    * *Rocky Linux*
    * *Alma Linux*
