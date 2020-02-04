# ccs-ci
Dockerfile to build a code composer studio container for continues integration/build/test

# To download on TI site :


# To use it:
 
## build
docker build -t ccs .

## run
docker run -ti -v C:\\workspace\\roomzscreen:/workdir ccs /bin/bash

## import project
/opt/ti/ccs/eclipse/eclipse -noSplash -data "/workspace" -application com.ti.ccstudio.apps.projectImport -ccs.location /workdir/<projectName>/

## build
/opt/ti/ccs/eclipse/eclipse -noSplash -data "/workspace" -application com.ti.ccstudio.apps.projectBuild  -ccs.workspace -ccs.setBuildOption com.ti.ccstudio.buildDefinitions.C6000_6.1.compilerID.QUIET_LEVEL com.ti.ccstudio.buildDefinitions.C6000_6.1.compilerID.QUIET_LEVEL.VERBOSE