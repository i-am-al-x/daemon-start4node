#!/bin/bash
#File "first-time-install-_xxxx_.sh
#Started by Alexander R Danel, 2020-04-26
#Copyright 2020 Alexander R Danel
#
#These instructions are about setting up the start-stop daemon within
#the unix hierarchy.
#
#The actor must have "sudo" capability.
#
#Presumes bundled product is already present on the machine, and has
#been unbundled in the "DISTRIB_WEB_DIR" directory.
#
#Resultant environment involves at least the following.
#For the custom adaptation of this hierarchy on a per applications basis,
#replace the words:
# - "node4cspa",
# - "cspa",
# - "curmap-org".
#
#	# Standard utilization of hierarchy by init and cron scripts
#	/etc/init.d/node4cspa		# start-stop script
#	/etc/sysconfig/node4cspa	# config for start-stop script
#	/etc/default/node4cspa		# optional extra configs?
#	/var/log/node4cspa/		# log files
#	/var/run/node4cspa.pid		# PID file
#	/etc/cron*/			# cron directories, as needed
#	(/lib/lsb/init-functions)	# (future)
#
#	# System level
#	/opt/local/bin/node4cspa	# node executable (sym-link to "node")
#	/opt/local/etc/keys/cspa/curmap-org/	# SSL Certificates
#
#	# Application level
#	/opt/web/cspa			# SYS_WEB_DIR
#
#To update the system so that the init script is run at boot-up time, 
#use Linux program:
#
#	chkconfig
#
#	(similar program on Mac is "sysconfig")
#
#The "chkconfig" program updates directories:
#	/etc/rc
#	/etc/rc*.d
#	/etc/rc*
#
#----------- uninstall ----------------------
#	sudo rm /etc/init.d/node4cspa
#	sudo rm /etc/sysconfig/node4cspa
#	#sudo rm /etc/default/node4cspa
#	sudo rm -rf /var/log/node4cspa/
#	sudo rm /var/run/node4cspa.pid
#	#	# System level
#	sudo rm /opt/local/bin/node4cspa
#	sudo rm -rf /opt/local/etc/keys/cspa/curmap-org/
#	#	# Application level
#	sudo rm -rf /opt/web/cspa
#
#-----------------------------------------------------------------------
set -x;
# App dependent
declare MY_APP_NM="cspa"
declare DAEMON_NM="node4${MY_APP_NM}"

# Environment dependent
declare DB_CHOICE="prod";

# Distribution methodology dependent
declare DISTRIB_WEB_DIR="${HOME}/cur_tech/web";

# Machine dependent
declare DNS_SHORT_NM=curmap-org;
declare REGULAR_NODE_EXE_PATH=$( which node )

echo "${REGULAR_NODE_EXE_PATH}"

# If "/usr/local/bin" then link in there.
# For CT AWS node servers, for now, it is in user dir, like:
#    ~/.nvm/versions/node/v13.8.0/bin/node 

# Link "node" program executable into /opt/local/bin.
[ -d /opt/local/bin ] || sudo mkdir -p -v /opt/local/bin

sudo ln -s "${REGULAR_NODE_EXE_PATH}" /opt/local/bin/$DAEMON_NM;
ls -l /opt/local/bin/$DAEMON_NM;

declare SYS_WEB_DIR="/opt/web/${MY_APP_NM}";

sudo mkdir -p -v "$SYS_WEB_DIR"

DIRS_TO_LINK="
ckedit-slink
client-slink
conf_samp-slink
nd_mod-slink
server-slink
vendor-slink
";

DIRS_TO_HARD_COPY="
std_images
schoollogos
";

# Do not link "site-admin-slink" because it contains the SSL information.
DIRS_NOT_LINKED="
config-slink
lcl_bin-slink
release-slink
site-admin-slink
";

for DIR_NM in $DIRS_TO_LINK ; do
  sudo ln -s "${DISTRIB_WEB_DIR}/${DIR_NM}" "$SYS_WEB_DIR"
done;

for DIR_NM in $DIRS_TO_HARD_COPY ; do
  if [ ! -d "$SYS_WEB_DIR/${DIR_NM}" ] ; then
    sudo ln -s "${DISTRIB_WEB_DIR}/${DIR_NM}" "$SYS_WEB_DIR"
  fi
done;

ls -l "$SYS_WEB_DIR"

sudo mkdir -p -v "$SYS_WEB_DIR/config"
DB_CONFIG_NM="configConnectToMsSql-${DB_CHOICE}.json";
sudo cp -p "${DISTRIB_WEB_DIR}/config-slink/${DB_CONFIG_NM}" "$SYS_WEB_DIR/config";
sudo chown root:root "$SYS_WEB_DIR/config/$DB_CONFIG_NM";
sudo chmod 600       "$SYS_WEB_DIR/config/$DB_CONFIG_NM";

# Idea:
# Maybe the "ssl" should be completely on its own.
# It has special security requirements.
declare DISTRIB_SITE_ADMIN_DIR="${DISTRIB_WEB_DIR}/site-admin-slink";
declare DISTRIB_START_STOP_DIR="${DISTRIB_SITE_ADMIN_DIR}/start-stop";

sudo mkdir -p -v "$SYS_WEB_DIR/start-stop"
(cd "$DISTRIB_START_STOP_DIR"; tar cf - .) | (cd "$SYS_WEB_DIR/start-stop"; sudo tar xvf - );

declare DISTRIB_SSL_DIR="${DISTRIB_SITE_ADMIN_DIR}/ssl";
[ -d /opt/local/etc/keys/${DNS_SHORT_NM} ] || sudo mkdir -p -v /opt/local/etc/keys/${DNS_SHORT_NM}
(cd "$DISTRIB_SSL_DIR/$DNS_SHORT_NM" && tar cf - .) | ( cd /opt/local/etc/keys/${DNS_SHORT_NM} && sudo tar xvf - );

(cd /opt/local/etc/keys/${DNS_SHORT_NM} &&  
  sudo chown root:root * &&
  sudo chmod 600 *;
);

ls -l /opt/local/etc/keys/${DNS_SHORT_NM}
 
sudo cp -p "${SYS_WEB_DIR}/start-stop/init.d/${DAEMON_NM}"   /etc/init.d/${DAEMON_NM};
sudo chown root:root /etc/init.d/${DAEMON_NM};
sudo cp -p "${SYS_WEB_DIR}/start-stop/sysconfig/${DAEMON_NM}-${DNS_SHORT_NM}" /etc/sysconfig/${DAEMON_NM};
sudo chown root:root /etc/sysconfig/${DAEMON_NM};

ls -l "${SYS_WEB_DIR}/start-stop/init.d/${DAEMON_NM}"   /etc/init.d/${DAEMON_NM};
ls -l "${SYS_WEB_DIR}/start-stop/sysconfig/${DAEMON_NM}" /etc/sysconfig/${DAEMON_NM};

sudo chown root:root  /etc/init.d/${DAEMON_NM};
sudo chmod 744        /etc/init.d/${DAEMON_NM};
sudo chown root:root  /etc/sysconfig/${DAEMON_NM};
sudo chown 644        /etc/sysconfig/${DAEMON_NM};

ls -l  /etc/init.d/${DAEMON_NM};
ls -l  /etc/sysconfig/${DAEMON_NM};

sudo mkdir /var/log/${DAEMON_NM};

# test it
sudo /etc/init.d/${DAEMON_NM} status;

# Might need to kill an existing "httpd" on port 
# After the port is clear, can start the daemon.

sudo /etc/init.d/${DAEMON_NM} start;

# Want the daemon to be restarted with reboot of computer.

sudo chkconfig --add ${DAEMON_NM}

set +x;
