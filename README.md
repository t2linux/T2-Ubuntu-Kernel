# T2 Ubuntu Kernel

Ubuntu/Mint kernel with Apple T2 patches built-in. This repo will try to keep up with kernel new releases.

**Note for Debian users :-** Since Debian doesn't support the kernels released in this repo, Debian users are suggested to use [this fork](https://github.com/andersfugmann/T2-Debian-Kernel) to get compatible kernels.

![Build Kernel Package](https://github.com/t2linux/T2-Ubuntu-Kernel/actions/workflows/kernel.yml/badge.svg?branch=LTS)

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

### Using the apt repo

Firstly add the [t2-ubuntu-repo](https://adityagarg8.github.io/t2-ubuntu-repo/) apt repo. You need to follow these steps to add it:

1. Identify your release codename. It is: 
  
    a) `jammy` for **Ubuntu 22.04**

    b) `mantic` for **Ubuntu 23.10**

    c) `noble` for **Ubuntu 24.04**

    You can also run `lsb_release -a` to identify your codename.

3. Run the following (taking `noble` as the example, just replace it with your release codename in the first line):

```bash
CODENAME=noble
curl -s --compressed "https://adityagarg8.github.io/t2-ubuntu-repo/KEY.gpg" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg >/dev/null
sudo curl -s --compressed -o /etc/apt/sources.list.d/t2.list "https://adityagarg8.github.io/t2-ubuntu-repo/t2.list"
echo "deb [signed-by=/etc/apt/trusted.gpg.d/t2-ubuntu-repo.gpg] https://github.com/AdityaGarg8/t2-ubuntu-repo/releases/download/${CODENAME} ./" | sudo tee -a /etc/apt/sources.list.d/t2.list
sudo apt update
```

Currently, 2 types of kernel variants are available. You can use anyone as per your choice:

1. Mainline kernels:

    If you want to install **Mainline** kernels, install `linux-t2` package:

    ```bash
    sudo apt install linux-t2
    ```

    **Note: The Mainline kernels are shipped by default if you have used the iso from [T2-Ubuntu](https://github.com/t2linux/T2-Ubuntu), but you STILL HAVE TO INSTALL THIS to receive kernel updates after installing Ubuntu**

2. LTS kernels:

    If you want to install **LTS** kernels, install `linux-t2-lts` package:

    ```bash
    sudo apt install linux-t2-lts
    ```

Now, whenever a new kernel is released, you can use **Software updater** or run `sudo apt upgrade` to get it.

#### Changing kernel variant:

If you want to change the kernel variant, say from Mainline to LTS, first install the package of the kernel, and then remove the current kernel. Eg, if you wanna switch to LTS from Mainline, run:

```bash
sudo apt install linux-t2-lts
sudo apt remove linux-headers-$(uname -r) linux-image-$(uname -r)
```

Simply replace `linux-t2-lts` in the above command with the kernel variant you want to use.

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
