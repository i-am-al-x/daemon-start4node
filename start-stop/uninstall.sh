#----------- uninstall ----------------------
# Customize this script, replacing "_xxxx_" with appropriate app name.
# See also notes about "MY_COMPANY-org", below.

# The file name conventions shown here work on AWS linux,
# but might need to be adjusted for a particular system.

#------ # Remove scripts at standard Unix start-stop file locations
sudo rm /etc/init.d/node4_xxxx_
sudo rm /etc/sysconfig/node4_xxxx_
sudo rm /etc/default/node4_xxxx_     # where appropriate

#------ # Remove run time generated files
sudo rm -rf /var/log/node4_xxxx_/
sudo rm     /var/run/node4_xxxx_.pid

#------ # Remove automatically created "run level" symbolic links
#	# The links were created with 'chkconfig' during installation.
#	# The links created by 'chkconfig' are named with a three 
#	# character prefix:
#	# - first char is either 'S' is for "start" or 'K' is for "kill", 
#	# - next two chars represent sequencing order.
#	# The 'chkconfig' program created these links based upon 
#	# instructions it found in the script "/etc/init.d/node4_xxxx_";
#	# see the script lines immediately following "BEGIN INIT INFO".
for RUN_LEVEL in 0 1 2 3 4 5 6 ; 
do
  rm /etc/rc.d/rc${RUN_LEVEL}.d/S??node4_xxxx_
  rm /etc/rc.d/rc${RUN_LEVEL}.d/K??node4_xxxx_
done

#------ # System level
#	# Alias for "node".
#	# The link by which the node program, e.g. "/usr/bin/node",
#	# is given an alias of the form "node4____"
sudo rm /opt/local/bin/node4_xxxx_

#	# App specific SSL certificate
#	# If your system uses "/opt/local/etc/_xxxx_/keys" then replace
#	# "MY_COMPANY-org" with the appropriate DNS inspired name, 
#	# typically using hyphen "-" instead of dot "."; 
#	# (so "-org" instead of ".org").
sudo rm -rf /opt/local/etc/keys/_xxxx_/MY_COMPANY-org/

#------ # Application level
#	# The server code.  
#	# Actual location may vary.
sudo rm -rf /opt/web/_xxxx_

#------ # the end
