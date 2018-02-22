# Set the base image
FROM ubuntu:16.04

# Dockerfile author / maintainer 
MAINTAINER Dario Lombardo <lomato@gmail.com>

RUN apt-get update
RUN apt-get upgrade -y
ADD debian-setup.sh /
RUN /debian-setup.sh --install-optional -y

#RUN apt-get install bash perl-base libgtk2.0-dev libpcap-dev bison flex make automake libtool python perl libgcrypt-dev libtool-bin libnl-3-dev qttools5-dev qttools5-dev-tools libgtk-3-dev libc-ares-dev libkrb5-dev libqt5svg5-dev lynx libsmi2-dev portaudio19-dev asciidoc libsbc-dev libgeoip-dev qtmultimedia5-dev liblua5.2-dev libnl-cli-3-dev libparse-yapp-perl qt5-default cmake libcap-dev liblz4-dev libsnappy-dev libspandsp-dev libxml2-dev libnghttp2-dev libssh-gcrypt-dev libgnutls28-dev ninja-build git -y

# Build this image with
# docker build --build-arg http_proxy=http://webproxy.be-secure.it:3128 -t crondaemon/wireshark .
#
# Run
# docker run --name ws -t crondaemon/wireshark
#
# info:
# https://deis.com/blog/2015/creating-sharing-first-docker-image/
# docker login
# docker push crondaemon/wireshark