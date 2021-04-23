# daemon-start4node

The methodology of _daemon-start4node_ provides standards compliant installation for servers utilizing _node.js_.  A Unix/Linux system administrator should use the scripts and recommendations found in _daemon-start4node_ to establish the server as a daemon.  The developer should incorporate _daemon-start4node_ early in the development cycle, so that the product is designed around the correct presumptions about how an installation is supposed to work.

At its core, _daemon-start4node_ provides a _start-stop_ script.  There are certain requirements and expectations that such a script must fulfill.  It must fit into the operating system's methodology.  It must be equally effective when run manually as when run under automation.  It must track the status of a process.  It must provide certain minimal commands which include _start_, _stop_, _restart_, and _status_.  It should provide for logs.  Preferably, it should encode within itself the information the sets up run level start-stop links.  

## Installation

Download and unwrap the package.  

## Usage

The package contains a directory _start-stop_.  This is a hierarchy that parallels the locations in the operating system hierarchy where scripts and files should go.  The files are templates.  The file names and file contents contain a token `\_xxxx\_`.  You replace this token with the name of your server.  Change both the file names and the contents of the files.

Extensive instructions and explanations are found in the files themselves.  The central script around which all else revolves is `start-stop/init.d/node4_xxxx_`.  Configuration parameters go in a different place; see `start-stop/sysconfig/node4_xxxx_`.

Actual installation at the operating system level will require the system administrator to put the start-stop script and the config file in place under the `/etc` directory. Then the system administrator will run either `chkconfig` or `systemctl`, to distribute links into the run-level directories.

The scripts should also be installed and used in the development environment.  The _go_ script under `start-stop/develop` shows how to adjust parameters to allow local operation.  The developer can then invoke `go start` and `go stop` and etc.

The _node_ interpreter is called indirectly, via a symbolic link.  This gives a unique name to the _node_ invocation, so that the process can be uniquely identified.  The name for this symbolic link is derived from the _node4\_xxxx\__ pattern; (therefore, this link, the start-stop script, and the config file all have the same name, but are in different places).  The symbolic link can be put anywhere; you adjust the variable `absolutePathToEXEC` to inform the start-stop script about the location.

The package also contains a script that is intended as the basis for creating an install script.  This is intended for projects that neeed to deploy a server to many machines, and want to automate that deployment process.

There is also a directory _ssh-info_ that is meant to help the developer create self signed certificates.  Such certificates are useful during development and test, to allow "https".

## License
[MIT](https://choosealicense.com/licenses/mit/)
