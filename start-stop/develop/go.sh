#!/bin/bash
# Script original name: daemon-start4node/start-stop/go.sh
# Copyright 2021 Alexander R Danel

# ----------------------------------------------------------------------
# PURPOSE:
#
#   This is a launch script in the "dev" environment, during development.
#   The idea is that since the "start-stop" scripts are going to be used
#   in production, the same scripts should be used in development.
#
#   You want to maintain similarity between the development versus production 
#   environments because this reduces the likelihood of nasty surprises that
#   might otherwise show up when your code goes into production.
#
#   Specifically, a daemon using the start-stop methodology will 
#   anticipate the following production situations:
#   (1) Any configuration parameters which are to be set by the system-admin 
#   must be exposed as environment variables within the start-stop 
#   config.  This is very different from the javaScript programmer's 
#   practice of putting config parameters into the code base as ".json" files.
#   The Unix/Linus standard is that such parameters are configured in the 
#   appropriate file, which is named ${daemonName} and is located under the 
#   "sysconfig" directory.  The parameters are passed into the "node" 
#   application via environment variables.
#   (2) In production, daemons write their log files to a system level 
#   location.  The daemon either stricktly uses "stdout" and "stderr", 
#   or accepts the name of an output location from an environment variable.
#
# ----------------------------------------------------------------------
# RECOMMENDED USAGE:
#
#   Presuming product is called ${MY_APP_NM}, and
#   presuming top level directory for development of product is
#
#             ~/${MY_APP_NM}
#
#   Follow the procedure below.  The eventual result will include a symbolic
#   link in your development directory where you are doing server development.
#   That link will give you a quick way to start and stop the server,
#   so that the start-stop method used in development is completely parallel
#   to the start-stop method that will be used in production.  
#
#   This documentation presumes you will name that link "go"; which is terse,
#   meaningful, and convenient.  The "go" file will be a sym-link to this 
#   script, something like:
#
#        ln -s start-stop/develop/go.sh  go
#
#   Then you can just type "go" and the operation to be performed. 
#   For example: 
#
#     go start
#     go restart
#     go stop
#
#   Arguments to the "go" script get replicated as arguments to the 
#   start-stop script.  For example, use "--help" to get usage options.
#
#   $ go --help
#   Usage:
#           node4_xxxx_           (status|show_config|logs|lognames)
#      sudo node4_xxxx_ [ --force ] (start|stop|restart)
#           node4_xxxx_ [ -n {line_count} ]    dumplogs
#           node4_xxxx_  --help
#   
#
# ----------------------------------------------------------------------
# INSTALLATION
#
#   The sample command lines below use "MY_APP_NM" to stand in for the 
#   (presumably short and simple) name of your app.  If you wish, you can
#   use the command lines directly, with copy and paste; presuming you 
#   have set the required vars in your shell, as shown here.  
#   The following assignments are examples that assume the name of 
#   your app is "travel", and etc., adjust appropriately.
#
#   name of server
# $ MY_APP_NM=travel       # example only
#
#   the daemon used throughout the system (replaces "node4_xxxx_")
# $ daemonName=node4${MY_APP_NM}
#
#   top level directory for developing the server
# $ MY_APP_REPO="$HOME/$MY_APP_NM"   # example only
#
#   temporary location where "daemon-start4node" was unpacked
# $ DAEMON_START4NODE="$HOME/tmp/daemon-start4node"   # example only
#
#   OK, with that done, the commands below should all work.
#   Of course, any line that starts with the "$" symbol is a shell command.
#
#   A reminder that the parts of a daemon are tied together by having 
#   the same name.  That name is expressed in this document as 
#   "node4${MY_APP_NM}" and in the script as "${daemonName}".  
#   The parts of a daemon, and their usual location in unix/linus 
#   (except that the "usual location" depends upon Unix flavor) are:
#
#       /opt/local/bin/${daemonName}    # the binary (which is "node")
#       /opt/${MY_APP_NM}/server        # server javascript code
#       /etc/init.d/${daemonName}       # the start-stop script
#       /etc/sysconfig/${daemonName}    # the basic config script
#       /etc/${daemonName}/             # dir w extended configuration (if any)
#       /var/log/${daemonName}/         # dir for logging
#       /etc/rc (and similar)  # Links used by OS at boot and shutdown.
#                              # Names like: S15${daemonName} K85${daemonName}
#       /var/run/${daemonName}/         # pid file, map name to process id
#
#   Some of this standard hierarchy needs to be duplicated in a location
#   under your control.  Execute the following commands.
#
# $ mkdir "$HOME/var"
# $ mkdir "$HOME/var/run"
# $ mkdir "$HOME/var/log"
# $ mkdir "$HOME/var/log/${daemonName}"
#
#   Copy entire subdirectory "daemon-start4node/start-stop" into the dev dir.
#
# $ (cd ${DAEMON_START4NODE}; tar cf - start-stop) | (cd "${MY_APP_REPO}"; tar xvf - )
#
#   So you now have
#             ${MY_APP_REPO}/start-stop
#
#   For the example shown above, you would now have:
#
#       $HOME/travel
#       $HOME/travel/server    # or whatever your development dir is
#       $HOME/travel/start-stop
#
#   This new hierarchy of files under "start-stop" should eventually
#   be added to your source-code-control, e.g. "git".  But first, 
#   complete the rest of these installation actions.
#
#   Go to the location of the start-stop script.
#
# $ cd ${MY_APP_REPO}/start-stop/init.d
#
#   Change the script name by replacing the place-holder "_xxxx_" with 
#   the app name.  The resulting name matches ${daemonName}.
#
# $ mv node4_xxxx_ node4${MY_APP_NM}
#
#   That completes the tasks for the "init.d" directory.
#
#   The configuration directory is called "sysconfig".  Go there.
#
# $ cd ${MY_APP_REPO}/start-stop/sysconfig
#
#   System level configuration for your server will be performed through 
#   environment variables.  Any parameter that changes according to where
#   the server is running (which machine, which environment) should be an
#   environment variable in the "sysconfig".  If your server doesn't work 
#   that way, then modify the server code.
#
#   Since this effort is about the "dev" environment, the name of your 
#   local version of the config should probably have a "-dev" suffix.
#   You might find that multiple configs need to be maintained in your code,
#   and you might even want to commit them to source code control.
#   The pattern of adding a suffix like "-dev", "-test", and "-prod"
#   facilitates a consistent approach.  
#
#   It will always be true that each of the environments "dev", "test",
#   and "prod" use different SSL certificates.  That, alone, is a reason to
#   have different configs for different environments.
#
#   The sample has a longer suffix; it is "-localhost-dev". The pattern
#   here is that the machine-id or the DNS is part of the suffix.  This
#   allows for maintaining as many configs as there are machines.  
#   For any given machine, the one appropriate config gets linked in as
#   the actual config.
#
#   Rename the local copy of the config file, giving it the name that follows
#   the convention for ${daemoneName} (that the name has "node4" prepended 
#   to the server name), but this time include also a suffix having "-dev" 
#   to clarify this is a particular instance of the config which is applicable
#   only to the "dev" environment.  The following command simply replaces 
#   the placeholder "_xxxx_" with the app name.
#
# $ mv node4_xxxx_-localhost-dev node4${MY_APP_NM}-localhost-dev
#
#   Note that at some later date, you will probably create other versions of 
#   the config, with suffixes that suggest what environment they are for.
#   So the "sysconfig" directory in your dev environment might include:
#
#       node4${MY_APP_NM}-localhost-dev
#       node4${MY_APP_NM}-website-com-test
#       node4${MY_APP_NM}-website-com-prod-example
#
#   You would do this if you want all the files saved in source-control,
#   such as "git".
#
#   The start-stop script (located in "init.d") will not recognize 
#   a file with a suffix like "-dev" attached, since the convention 
#   requires all names to be just ${daemonName}, without the "-dev".
#   Therefore, make a symbolic link that has a name exactly matching 
#   ${daemonName}.  The only difference between the link name 
#   versus the file name is that for the link, the suffix "-dev" is omitted.
#
# $ ln -s node4${MY_APP_NM}-localhost-dev node4${MY_APP_NM}
#
#   Edit the configuration file, and put in all environment variables needed
#   to run the program you are developing.
#
# $ vi node4${MY_APP_NM}-localhost-dev
#  ... (do the edit) ...
#
#   That completes work on the file "node4${MY_APP_NM}" located in
#   the "sysconfig" directory.  During development, edit that file 
#   when you need to introduce new parameters.
#
#   The actual development will, of course, occur in the server dir,
#   and so that's where you will be using the "go" script.
#   For the sake of consistent source code control, you should keep the 
#   "go.sh" script where it is, under the "start-stop/develop" directory.
#   You will create a symbolic link to "go.sh" in the server development 
#   directory.  Go to the server dir.
#
# $ cd ${MY_APP_REPO}/server
#
#   Create the link; it is pointing at "start-stop/develop/go.sh", 
#   and it is named "go".
#
# $ ln -s ${MY_APP_REPO}/start-stop/develop/go.sh  go
#
#   Edit the script.
#   Adjust the script parameters "MY_APP_NM" and "START_STOP_DIR".
#   The "START_STOP_DIR" is your local version of the "start-stop"
#   directory; the one created with "tar" at the begining of these
#   instructions.  It is the equivalent of "${MY_APP_REPO}/start-stop",
#   (but "MY_APP_REPO" is not defined in the script, since that would
#   not be appropriate in a production environment.)
#
# $ vi  go
#  ... (do the edit) ...
#
#   That completes set up.
#
#   Use the script to start and stop the server:
#
# $ ./go status
# $ ./go start
# $ ./go restart
# $ ./go stop
# $ ./go help
# $ ...etc...
#
#
# ----------------------------------------------------------------------

#set -x

declare MY_APP_NM_TEMP="_xxxx_"
declare daemonName_TEMP="node4${MY_APP_NM_TEMP}"

declare START_STOP_DIR_TEMP="$HOME/repos/${MY_APP_NM_TEMP}/start-stop";

# Set and export environment variables
export daemonSysconfigName="$START_STOP_DIR/sysconfig/${daemonName_TEMP}-localhost-dev";
[ -r ${daemonSysconfigName} ] || {
  echo "This user cant read file daemonSysconfigName: ${daemonSysconfigName}";
  return 1;
}
  
#>export WEB_DIR="$HOME/repos/${MY_APP_NM_TEMP}/web-server"; # or wherever you put the server code
#>[ -x ${WEB_DIR} ] || {
#>  echo "This user cant change directory to WEB_DIR: ${WEB_DIR}";
#>  return 1;
#>}
  
# Execute the script that launches the server daemon
"$START_STOP_DIR/init.d/${daemonName_TEMP}" "$@"

