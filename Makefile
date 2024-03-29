
PREFIX  = /storage

CONFIG       = $(PREFIX)/.config

SYSTEMD_DEST = $(PREFIX)/.config/system.d/
SYSTEMD_CFG  = $(PREFIX)/.config/default
SCRIPT_DEST  = $(PREFIX)/bin
LIRC_DEST    = $(PREFIX)/etc/lirc
VDR_ETC      = $(PREFIX)/UBUNTU/etc/vdr/
VDR_CONF     = $(VDR_ETC)/conf.avail
VDR_HOME     = $(PREFIX)/UBUNTU/var/lib/vdr

install:
	mkdir -p $(SCRIPT_DEST)
	install --mode=755 -D ./scripts/* $(SCRIPT_DEST)
	mkdir -p $(SYSTEMD_DEST)
	install --mode=644 -D ./systemd/units/* $(SYSTEMD_DEST)
	mkdir -p $(SYSTEMD_CFG)
	if ! test -f $(SYSTEMD_CFG)/vdrtft; then \
		install --mode=644 -D ./systemd/default/vdrtft $(SYSTEMD_CFG)/vdrtft; \
	fi
	install --mode=644 -D ./env/.bashrc_ubuntu $(PREFIX)/.bashrc_ubuntu;
	install --mode=644 -D ./env/.gitconfig $(PREFIX)/.gitconfig;
	install --mode=644 -D ./env/.bash_aliases $(PREFIX)/.bash_aliases;
	mkdir -p $(PREFIX)/.gitenv
	install --mode=644 -D ./env/.gitenv/* $(PREFIX)/.gitenv/;
	if ! test -f $(PREFIX)/.bashrc; then \
		install --mode=644 -D ./env/.bashrc $(PREFIX)/.bashrc; \
	fi
	if ! test -f $(PREFIX)/.profile; then \
		install --mode=644 -D ./env/.profile $(PREFIX)/.profile; \
	fi
	mkdir -p $(LIRC_DEST)
	if ! test -f $(LIRC_DEST)/lircrc; then \
		install --mode=644 -D ./etc/lircrc $(LIRC_DEST)/lircrc; \
	fi
	if ! test -f $(VDR_CONF)/softhdodroid.conf; then \
		install --mode=644 -D ./vdr.conf/softhdodroid.conf $(VDR_CONF)/softhdodroid.conf; \
	fi
	chown -R vdr:vdr ~vdr/ $(VDR_ETC)
	sed -i s/"^#*Port 22.*"/"Port 2022"/g /etc/ssh/sshd_config

initial-install: install
	install --mode=644 -D ./vdr.conf/00-vdr.conf $(VDR_ETC)/conf.d/
	install --mode=644 -D ./vdr.conf/channels.conf $(VDR_HOME)
	install --mode=644 -D ./vdr.conf/remote.conf $(VDR_HOME)
	install --mode=644 -D ./vdr.conf/svdrphosts.conf $(VDR_ETC)
	cp -a ./config/* $(CONFIG)/
