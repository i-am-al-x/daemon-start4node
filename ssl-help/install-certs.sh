# !/bin/bash
# File ".../ssl/install-certs.sh.sh"
# Started by Alexander R Danel, 2020-05-04
# Copyright 2020 Alexander R Danel
# 
# Help regarding installing SSL/TLS (HTTPS) certificate and key files, within a
# typical unix hierarchy.
# 
# The actor must have "sudo" capability.
# -----------------------------------------------------------------------

# === Where do the Files Go? ===

# The location for ssl/tls certificates (certificate and key files) varies 
# according to the flavor of Unix/Linux.  The following "serverfault" page 
# provides some people's findings; see especially post by "Timmmm".  
#
# https://serverfault.com/questions/62496/ssl-certificate-location-on-unix-linux
#
# Some typical locations under which ssl/tls information is found are:
#    /etc/ssl/...		(Debian, etc.)
#    /etc/pki/tls/...		(including various Red Hat, others)
#    /usr/local/share/...	(FreeBSD, Apple)
#
# Some systems use subdirectories to segregate the private information from 
# public information, typically the two sub-directories are named "private" 
# and "cert".  This method been called "unwieldy" in one of the "serverfault" comments,
# comments, but the method is in wide use.
#
#	/etc/pki/tls/certs		# SSL Private keys
#	/etc/pki/tls/private		# SSL Certificates
#
# ... or ...
#
# 	/etc/ssl/private/		# SSL Private keys
# 	/etc/ssl/certs/			# SSL Certificates
#
# One way to satisfy more people's expectations is to use symbolic links.
# For example, this is done on AWS Linux:
#
#    ln -s /etc/pki/tls/certs   /etc/ssl/certs
#    ln -s /etc/pki/tls/private /etc/ssl/private
#
# Sometimes a machine has more than one set of certs; this will be the case if the 
# machine is served by more than one DNS name.  When multiple sets need to be 
# accommodated, care should be taken to have file names that are unique and are 
# suggestive of the associated cert.  
#
# An alternative technique is to create sub-directories that bare the DNS name,
# and put everything, both public and private into that dir, but take care to 
# set permissions correctly.
#
# $ ls -l /etc/ssl/excellentExampleSite.com/
# -rw-r--r-- 1 root root 1520 Mar 24 06:26 AddTrustExternalCARoot.crt
# -rw-r--r-- 1 root root 1106 Mar  9 13:41 csrcorg.csr
# -rw-r--r-- 1 root root 2414 Mar 24 06:26 EXCELLENTEXAMPLESITE.COM.crt
# -rw-r--r-- 1 root root 5627 Mar 24 12:27 ov_chain.txt
# -rw-r--r-- 1 root root 2150 Mar 24 06:26 OV_NetworkSolutionsOVServerCA2.crt
# -rw-r--r-- 1 root root 1955 Mar 24 06:26 OV_USERTrustRSACertificationAuthority.crt
# -rw------- 1 root root 1704 Mar  9 13:41 pkcorg.key
#
# The important thing is:
# - Whatever the location, make sure the relevant programs are informed.
#   Specifically, make sure the server being installed gets the config info.
# - Make sure the ownership and permissions are correctly set up.
#	sudo chown root:root *.key *.crt *.pem (...etc...)
#	sudo chmod 600       *.key 
#
# Information about what the filename suffixes mean:
# https://serverfault.com/questions/9708/what-is-a-pem-file-and-how-does-it-differ-from-other-openssl-generated-key-file

# The following is intended as a set of suggestions outlining the task, 
# and should not be executed as an automated script.
exit 1;

#set -x;

declare CERT_ARCHIVE_FILE=/tmp/myCertAuthority.tar;

sudo ln -s /etc/pki/tls/certs   /etc/ssl/certs    2>/dev/null
sudo ln -s /etc/pki/tls/private /etc/ssl/private  2>/dev/null

# Get a list of the contents of the archive
tar tf $CERT_ARCHIVE_FILE 

# Check for file-name collisions between the incoming files versus
# the files already in the target directory.
# If collisions, you will need to first un-tar into a temp directory,
# and make some name changes.

# ... after cleaning up any collisions...

cd /etc/pki/tls/certs

sudo tar xvf $CERT_ARCHIVE_FILE 

for NEWFILE in $( tar tf $CERT_ARCHIVE_FILE ); do
  sudo chown root:root $NEWFILE;
  sudo chmod 644       $NEWFILE;
done;

for KEYFILE in $( tar tf $CERT_ARCHIVE_FILE | egrep -e '\.key$' ); do
  sudo chmod 600       $KEYFILE;
  sudo mv $KEYFILE /etc/pki/tls/private
done;

# That should do it.

