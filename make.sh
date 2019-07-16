#!/bin/bash

### FIXME: seems to be broken, cannot `make lib389-install`

init_once() {
	  sudo groupadd -g 389 dirsrv
	  sudo useradd -g dirsrv -u 389 dirsrv
}

prep() {
	  autoreconf -fiv
	  ./configure \
		    --prefix=/usr \
		    --enable-debug --with-openldap --enable-cmocka \
		    --with-systemd \
		    --with-systemdsystemunitdir=/usr/lib/systemd/system \
		    --with-systemdsystemconfdir=/etc/systemd/system \
		    --with-systemdgroupname=dirsrv
}

build() {
	  build_srv
	  build_lib389
	  build_console
	  #make check
}

install() {
	  install_srv
    install_lib389
    install_console
}

build_srv() { make -j2 ; }
install_srv() { sudo make install ; }
refresh_srv() {
	  build_srv
	  install_srv
}

build_lib389() { make -j2 lib389 ; }
install_lib389() { sudo make lib389-install ; }
refresh_lib389 () {
	  build_lib389
	  install_lib389
}

build_console() {
    make 389-console-clean
    make -j2 389-console
}
install_console() { sudo make 389-console-install ; }
refresh_console () {
	  build_console
	  install_console
}

