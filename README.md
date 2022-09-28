# T2 Ubuntu Kernel

Ubuntu/Mint/Debian kernel with Apple T2 patches built-in. This repo will try to keep up with kernel new releases.

![Build Kernel Package](https://github.com/t2linux/T2-Ubuntu-Kernel/actions/workflows/build.yml/badge.svg?branch=Mainline)

This project is closely inspired by mikeeq/mbp-fedora-kernel and marcosfad/mbp-ubuntu-kernel. Thank you @mikeeq and @marcosfad for the scripts and setup.

Special thanks to @Redecorating for the CI.

**If this repo helped you in any way, consider inviting a coffee to the people in the [credits](https://github.com/t2linux/T2-Ubuntu-Kernel#credits) (links given [here](https://wiki.t2linux.org/contribute/)).**

## Pre installation steps

Releases starting from 5.16.2 and 5.15.16 (LTS) have apple-bce and apple-ibridge drivers built-into the kernel. Thus, you may remove the dkms versions of them by running :-

```
sudo rm -r /usr/src/apple-bce*
sudo rm -r /usr/src/apple-ibridge*
sudo rm -r /var/lib/dkms/apple-bce
sudo rm -r /var/lib/dkms/apple-ibridge
```

In case you have used an iso with kernel version **5.8.x or lower**, then the above steps are compulsory.

If you want to install an older kernel (i.e. older than 5.16.2 or 5.15.16 (LTS)), then follow the [DKMS Guide](http://wiki.t2linux.org/guides/dkms/) to uninstall old drivers and get new drivers for the kernels. It is required only once and must be done before installing a kernel from here.

## INSTALLATION

### Using the Kernel Upgrade script

Firstly add the **t2-ubuntu-repo** apt repo :-

```bash
curl -s --compressed "https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg >/dev/null
sudo curl -s --compressed -o /etc/apt/sources.list.d/t2.list "https://adityagarg8.github.io/t2-ubuntu-repo/t2.list"
sudo apt update
```

Then, install the script by running :-

```bash
sudo apt install t2-kernel-script
```

If you want to install the latest LTS kernels, then run this instead :-

```bash
sudo apt install t2-kernel-script-lts
```

Now, whenever you wish to upgrade your kernel, run :-

```bash
update_t2_kernel -v
```

### Download package manually

Download the .deb packages of **linux-headers** and **linux-image** of the kernel you wish to install from the [releases](https://github.com/t2linux/T2-Ubuntu-Kernel/releases) section.

Install **linux-headers** first and then **linux-image** using `apt` and restart your Mac. In case you do not know how to do so, follow the instructions given below. Else you are good to go.

On terminal, type `sudo apt install ` and then drag and drop the **linux-headers** file to the terminal and press enter/return key.

Do the similar process for **linux-images** package.

Restart your Mac.

### Building yourself

Clone the repo using
```bash
git clone https://github.com/t2linux/T2-Ubuntu-Kernel
```

Open a terminal window and run

```bash
cd T2-Ubuntu-Kernel
sudo ./build.sh
```

The kernel shall take around an hour to compile. After that you shall find three .deb packages in `/root/work`.

Install the **linux-headers** package first using `apt`. In case you do not know how to do so, follow the instructions described in the above **The easy way** section. Similarly install the **linux-image** package too.

Restart your Mac.

You may then delete the `/root/work` directory using `sudo rm -r /root/work` to free up space.

## Docs

- Discord: <https://discord.gg/Uw56rqW>
- WiFi firmware:
  - <https://wiki.t2linux.org/guides/wifi/>
- blog `Installing Fedora 31 on a 2018 Mac mini`: <https://linuxwit.ch/blog/2020/01/installing-fedora-on-mac-mini/>
- iwd:
  - <https://iwd.wiki.kernel.org/networkconfigurationsettings>
  - <https://wiki.archlinux.org/index.php/Iwd>
  - <https://www.vocal.com/secure-communication/eap-types/>

### Ubuntu

- <https://wiki.ubuntu.com/KernelTeam/GitKernelBuild>
- <https://help.ubuntu.com/community/Repositories/Personal>
- <https://medium.com/sqooba/create-your-own-custom-and-authenticated-apt-repository-1e4a4cf0b864>
- <https://help.ubuntu.com/community/Kernel/Compile>
- <https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel>
- <https://www.linux.com/training-tutorials/kernel-newbie-corner-building-and-running-new-kernel/>
- <https://wiki.ubuntu.com/KernelTeam/KernelMaintenance>

## Credits

- @Redecorating - thanks for editing the scripts and CI for Ubuntu
- @fishpm-anu - thanks for the kernel upgrade script
- @marcosfad - thanks for the original script for Ubuntu
- @MCMrARM - thanks for all RE work
- @ozbenh - thanks for submitting NVME patch
- @roadrunner2 - thanks for SPI (touchbar) driver
- @aunali1 - thanks for ArchLinux Kernel CI and active support
- @jamlam - thanks for providing the Correlium wifi patch
- @ppaulweber - thanks for keyboard and Macbook Air patches
- @mikeeq - thanks for the fedora kernel project and compilation scripts
