# Repo

This project contains a personal Debian package repository that could be served on GitHub Page.
It also contains guides on how to build a Debian package, create repository, and use the repository.

## Creating a Debian Package

### Structuring the Package

- Create a directory using name that follow standard Debian notation for package name.
  usually it is all lowercase with the following format `<PROJECT>_<MAJOR-VER>.<MINOR-VER>-<PKG-REVISION>_<ARCHITECTURE>`. _(example: `libsomething_1.0-1_amd64`)_
- Pretend the directory you just created to be the root of the system file.
- Put files that will be installed correspond to their install path. _(example: put file that will be installed on `/usr/lib/libsomething.so` to `libsomething_1.0-1_amd64/usr/lib/libsomething.so`)_
- Create a `DEBIAN` directory inside the project directory.
  This directory will be used to put metadata and configuration files of the package.
- The configuration files are optional, but the metadata file is a must.
  > For more information about the configuration files, please refer [here](https://www.debian.org/doc/manuals/maint-guide/dreq.en.html).
- Create `DEBIAN/control` for the metadata file.
  The metadata file atleast must contains information like the following example:
  ```
  Package: libsomething
  Version: 1.0-1
  Section: base
  Priority: optional
  Architecture: i386
  Depends: somepackage (>= 1.0.0), someotherpackage (>= 1.2.5)
  Maintainer: Your Name <your@email.com>
  Description: short description
   very long
   description
  ```
  > For more information about the metadata files, please refer [here](https://www.debian.org/doc/debian-policy/ch-controlfields.html)
- Watch for the file permission _(read, write, and execute permission)_.
  Make sure executable files in the package already have an execute permission.
- After the package already structured, continue to build the package as a Debian package.

### Building the Package

- Build the directory as a Debian package:
  ```bash
  $ dpkg-deb --build <package_directory>
  ```
  > If the `dpkg-deb` has not been installed, install it using `$ sudo apt install dpkg`.

## Creating a Debian Package Repository

### Structuring the Repository

- The repository consists of 2 main directory, `dists` that contains package lists and `pool` that contains the package files.
  - The `dists` directory should be structured using the following format `dists/<OS-RELEASE>/main/binary-<ARCHITECTURE>/`. _(example: `dists/bionic/main/binary-amd64`)_
  - The `pool` directory should be structured using the following format `pool/main/<PACKAGE>/<PACKAGE-DEB>`. _(example: `pool/main/libsomething/libsomething_1.0-1_amd64.deb`)_

### Making the Repository to be Signed

- Create a new gpg key for this repository.
  ```bash
  $ gpg --gen-key
  ```
  > Note: Make sure to export the key so it could be used later by other user to update the repository.
  > To export the key, use the following command `$ gpg --export-secret-keys <NAME> > <PATH-TO>/<KEYNAME>.key`
- Export the public key for the repository and put it to the project root.
  ```bash
  $ gpg --armor --export <NAME> > <KEYNAME>.asc
  ```

### Adding a New Package to the Repository

- Put all new release of Debian packages inside their corresponding package in `pool` directory. _(example: put `libsomething_1.0-1_amd64.deb` inside `pool/main/libsomething`)_
- Update the package list for each architecture under `dists/<OS-RELEASE>/main` directory.
  ```bash
  $ apt-ftparchive --arch <ARCHITECTURE> packages pool > <PATH-TO>/binary-<ARCHITECTURE>/Packages
  ```
  > If the `apt-ftparchive` has not been installed, install it using `$ sudo apt install apt-utils`.
- Also update the gzip version of the package list for every new package list.
  ```bash
  $ gzip -kf <PATH-TO>/Packages
  ```
- Update the release files for each os release under `dists/<OS-RELEASE>` directory.
  ```bash
  $ cd dists/<OS-RELEASE>
  $ apt-ftparchive release . > Release
  $ gpg --clearsign -o InRelease Release
  $ gpg -abs -o Release.gpg Release
  ```

### Serving the Repository on GitHub Page

- Clone this project to your GitHub repository as `repo`.
- On the repository settings, under the `GitHub Page`, Set the `Source` to be the branch that will be served on the GitHub Page.
- The repository later could be accessed under `<USER>.github.io/repo`.

## Using The Repository

### Adding the Public Key

- Public key is used to sign this repository, so it could be accepted by the Debian packaging system in the client computer.
- Add the public key of the repository to the local system.
  ```bash
  $ curl -s <ADDRESS-TO>/repo/<KEYNAME>.asc | sudo apt-key add -
  ```

### Adding the Repository to the Source List

- Add the repository to the source list.
  ```bash
  $ sudo sh -c 'echo "deb [arch=<ARCHITECTURE>] <ADDRESS-TO>/repo $(lsb_release -sc) main" > /etc/apt/sources.list.d/<REPOSITORY-NAME>.list'
  ```
- Update the package list in repositories.
  ```bash
  $ sudo apt update
  ```