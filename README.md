<!-- Phishkit -->

<p align="center">
  <b>Phishkit - Automated Phishing Tool</b>
</p>

<p align="center"><b>A beginners friendly, Automated phishing tool with 30+ templates.</b></p>

##

<h3><p align="center">Disclaimer</p></h3>

<i>Any actions and or activities related to <b>Phishkit</b> is solely your responsibility. The misuse of this toolkit can result in <b>criminal charges</b> brought against the persons in question. <b>The contributors will not be held responsible</b> in the event any criminal charges be brought against any individuals misusing this toolkit to break the law.

<b>This toolkit contains materials that can be potentially damaging or dangerous for social media</b>. Refer to the laws in your province/country before accessing, using,or in any other way utilizing this in a wrong way.

<b>This Tool is made for educational purposes only</b>. Do not attempt to violate the law with anything contained here. <b>If this is your intention, then Get the hell out of here</b>!

It only demonstrates "how phishing works". <b>You shall not misuse the information to gain unauthorized access to someones social media</b>. However you may try out this at your own risk.</i>

##

### Features

- Latest and updated login pages.
- Beginners friendly
- Multiple tunneling options
  - Localhost
  - Cloudflared
  - LocalXpose
- Mask URL support 
- Docker support

##

### Installation

- Just, Clone this repository -
  ```
  git clone --depth=1 https://github.com/ERA/phishkit.git
  ```

- Now go to cloned directory and run `phishkit.sh` -
  ```
  $ cd phishkit
  $ bash phishkit.sh
  ```

- On first launch, It'll install the dependencies and that's it. ***Phishkit*** is installed.

##

### Installation (Termux)
You can easily install phishkit in Termux by using tur-repo
```
$ pkg install tur-repo
$ pkg install phishkit
$ phishkit
```
### A Note : 
***Termux discourages hacking*** .. So never discuss anything related to *phishkit* in any of the termux discussion groups. For more check : [wiki](https://wiki.termux.com/wiki/Hacking)

##



##

### Installation via ".deb" file

- Download `.deb` files from the [**Latest Release**](https://github.com/ERA/phishkit/releases/latest)
- If you are using ***termux*** then download the `*_termux.deb`

- Install the `.deb` file by executing
  ```
  apt install <your path to deb file>
  ```
  Or
  ```
  $ dpkg -i <your path to deb file>
  $ apt install -f
  ```

##

### Run on Docker

- Docker Image Mirror:
  - **DockerHub** : 
    ```
    docker pull erahacker/phishkit
    ```
  - **GHCR** : 
    ```
    docker pull ghcr.io/ERA/phishkit:latest
    ```

- By using the wrapper script [**run-docker.sh**](https://raw.githubusercontent.com/ERA/phishkit/master/run-docker.sh)

  ```
  $ curl -LO https://raw.githubusercontent.com/ERA/phishkit/master/run-docker.sh
  $ bash run-docker.sh
  ```
- Temporary Container

  ```
  docker run --rm -ti erahacker/phishkit
  ```
  - Remember to mount the `auth` directory.

##

<details>
  <summary><h3>Dependencies</h3></summary>

<b>Phishkit</b> requires following programs to run properly - 
- `git`
- `curl`
- `php`

> All the dependencies will be installed automatically when you run **Zphisher** for the first time.
</details>

<details>
  <summary><h3>Tested on</h3></summary>

- **Ubuntu**
- **Debian**
- **Arch**
- **Manjaro**
- **Fedora**
- **Termux**
</details>

##



##

### Author:
Created by **ERA** - Security Researcher & Developer


### *Special Thanks to:*

- **phd security** - For continuous support and guidance
- **1RaY-1, Aditya Shakya, Ali Milani, AmnesiA, KasRoudra, Moises Tapia, Mr.Derek, Mustakim Ahmed, sepp0, TripleHat, Yisus7u7** - Contributors and supporters

<!-- // -->
