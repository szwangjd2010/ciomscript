CIOM
Automation framework for Continuous Integration & Operation Maintenance 

support following:
linux + j2ee
win + .net
ios
andriod 
...
platform automation


Cluster nodes
1) master node
linux + jenkins
export CIOM_HOME="/opt/ciom"
export CIOM_SCRIPT_HOME="$CIOM_HOME/ciomscript"
export CIOM_VCA_HOME="$CIOM_HOME/ciomvca"
export CIOM_SLAVE_WIN_WORKSPACE="$CIOM_HOME/ciom.slave.win.workspace"
export CIOM_SLAVE_OSX_WORKSPACE="$CIOM_HOME/ciom.slave.osx.workspace"


2) win slave node
win7/win2008 srv + jenkins
add following system environment variables
CIOM_HOME
CIOM_SCRIPT_HOME
CIOM_WIN_WORKSPACE


3) osx slave node
osx 10.9 + jenkins + xcode

