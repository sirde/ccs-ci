FROM ubuntu:18.04

LABEL maintainer="Cedric Gerber <gerber.cedric@gmail.com>"

#Install all packages needed
#http://processors.wiki.ti.com/index.php/Linux_Host_Support_CCSv6

RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
  libc6:i386                    \
  libasound2                    \
  libusb-0.1-4                  \
  libstdc++6					\
  libxt6						\
  libcanberra-gtk-module        \
  unzip         				\
  wget                          \
  software-properties-common    \
  build-essential               \
  ca-certificates               \
  curl                          \
  libgconf-2-4                  \
  libdbus-glib-1-2              \
  libpython2.7                  \
  python2.7                     \
  libxtst6                      \
  at-spi2-core                  \
  binutils
  
# Python setup
#RUN add-apt-repository ppa:jonathonf/python-3.6
#RUN apt-get update && apt-get install -y \
#  python3-pip               \
#  python3.6
RUN pip3 install --upgrade pip
RUN pip3 install teamcity-messages

# Install missing library
WORKDIR /ccs_install

RUN export JAVA_TOOL_OPTIONS=-Xss1280k

# Install ccs in unattended mode
#https://e2e.ti.com/support/development_tools/code_composer_studio/f/81/t/374161

ENV PATH="/scripts:${PATH}"

ADD simplelink_cc32xx_sdk_3_40_00_05.run /ccs_install
RUN /ccs_install/simplelink_cc32xx_sdk_3_40_00_05.run --mode unattended

# Download and install CCS
#ADD CCS9.2.0.00013_linux-x64 /ccs_install
#RUN /ccs_install/ccs_setup_9.2.0.00013.bin --mode unattended --prefix /opt/ti --enable-components PF_MSP430,PF_CC3X


RUN curl -L http://software-dl.ti.com/ccs/esd/CCSv9/CCS_9_2_0/exports/CCS9.2.0.00013_linux-x64.tar.gz | tar xvz --strip-components=1 -C /ccs_install \
    && /ccs_install/ccs_setup_9.2.0.00013.bin --mode unattended --prefix /opt/ti --enable-components PF_MSP430,PF_CC3X \
    && rm -rf /ccs_install/
#This fails silently: check result somehow


#Install latest compiler
RUN cd /ccs_install \
    && wget -q http://software-dl.ti.com/codegen/esd/cgt_public_sw/TMS470/18.12.4.LTS/ti_cgt_tms470_18.12.4.LTS_linux_installer_x86.bin \
    && chmod 777 /ccs_install/ti_cgt_tms470_18.12.4.LTS_linux_installer_x86.bin \
    && ls -l /ccs_install \
    && /ccs_install/ti_cgt_tms470_18.12.4.LTS_linux_installer_x86.bin --prefix /opt/ti --unattendedmodeui minimal \
    && rm -rf /ccs_install/

RUN cd /ccs_install \
    && wget -q http://software-dl.ti.com/codegen/esd/cgt_public_sw/MSP430/18.12.4.LTS/ti_cgt_msp430_18.12.4.LTS_linux_installer_x86.bin \
    && chmod 777 /ccs_install/ti_cgt_msp430_18.12.4.LTS_linux_installer_x86.bin \
    && ls -l /ccs_install \
    && /ccs_install/ti_cgt_msp430_18.12.4.LTS_linux_installer_x86.bin --prefix /opt/ti --unattendedmodeui minimal \
    && rm -rf /ccs_install/


ENV PATH="/opt/ti/ccs/eclipse:${PATH}"

# workspace folder for CCS
RUN mkdir /workspace

# directory for the ccs project
VOLUME /workdir
WORKDIR /workdir

# Pre compile libraries needed for the msp to avoid 6min compile during each build
ENV PATH="${PATH}:/opt/ti/ccs/tools/compiler/ti-cgt-msp430_18.12.3.LTS/bin"
RUN /opt/ti/ccs/tools/compiler/ti-cgt-msp430_18.12.3.LTS/lib/mklib --pattern=rts430x_sc_sd_eabi.lib

# if needed
#ENTRYPOINT []