FROM ubuntu:14.04
MAINTAINER Pablo M Sobrado <pasogo91@gmail.com>

#==========================
# Build arguments
#==========================

ARG ANDROID_SDK_VERSION=23
ARG JAVA_VERSION=8
ARG IONIC_VERSION=1.7.14
ARG CORDOVA_VERSION=6.2.0
ARG VNC_PASSWD=1234

#==========================
# Env variables
#==========================

ENV SHELL "/bin/bash"
ENV X11_RESOLUTION "480x600x24"
ENV DISPLAY :1
ENV VNC_PASSWD ${VNC_PASSWD}
ENV DEBIAN_FRONTEND noninteractive
ENV ANDROID_SDK_VERSION ${ANDROID_SDK_VERSION}
ENV ANDROID_SDKTOOLS_VERSION 24.4.1
ENV JAVA_VERSION ${JAVA_VERSION}
ENV IONIC_VERSION ${IONIC_VERSION}
ENV CORDOVA_VERSION ${CORDOVA_VERSION}
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools
ENV SDK_PACKAGES \
platform-tools,\
build-tools-23.0.3,\
build-tools-23.0.2,\
build-tools-23.0.1,\
build-tools-22.0.1,\
android-23,\
android-22,\
sys-img-armeabi-v7a-android-$ANDROID_SDK_VERSION,\
sys-img-x86_64-android-$ANDROID_SDK_VERSION,\
sys-img-x86-android-$ANDROID_SDK_VERSION,\
sys-img-armeabi-v7a-google_apis-$ANDROID_SDK_VERSION,\
sys-img-x86_64-google_apis-$ANDROID_SDK_VERSION,\
sys-img-x86-google_apis-$ANDROID_SDK_VERSION,\
addon-google_apis-google-$ANDROID_SDK_VERSION,\
source-$ANDROID_SDK_VERSION,extra-android-m2repository,\
extra-android-support,\
extra-google-google_play_services,\
extra-google-m2repository

#==========================
# Add external files
#==========================

ADD assets/etc/apt/apt.conf.d/99norecommends /etc/apt/apt.conf.d/99norecommends
ADD assets/etc/apt/sources.list /etc/apt/sources.list

#==========================
# Install necessary packages, Appium and NPM
#==========================

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB9B1D8886F44E2A \
  && apt-get update -y \
  && apt-get -y --no-install-recommends install \
    apt-transport-https \
    build-essential \
    curl \
    g++ \
    git \
    lib32gcc1 \
    lib32ncurses5 \
    lib32stdc++6 \
    lib32z1 \
    libc6-i386 \
    libgconf-2-4 \
    libvirt-bin \
    libxi6 \
    make \
    openjdk-${JAVA_VERSION}-jdk \
    psmisc \
    python \
    python-software-properties \
    qemu-kvm \
    software-properties-common \
    unzip \
    wget \
    x11vnc \
    xvfb \
  && curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && apt-get -qqy clean && rm -rf /var/cache/apt/* \
  && npm install -g bower gulp cordova@${CORDOVA_VERSION} ionic@${IONIC_VERSION} \
  && ln -s $ANDROID_HOME/platform-tools/adb /usr/local/sbin/adb
    
#==========================
# Install Android SDK's and Platform tools
#==========================
    
RUN wget --progress=dot:giga -O /opt/android-sdk-linux.tgz \
    https://dl.google.com/android/android-sdk_r$ANDROID_SDKTOOLS_VERSION-linux.tgz \
  && tar xzf /opt/android-sdk-linux.tgz -C /tmp \
  && rm /opt/android-sdk-linux.tgz \
  && mv /tmp/android-sdk-linux $ANDROID_HOME \
  && echo 'y' | $ANDROID_HOME/tools/android update sdk -s -u -a -t ${SDK_PACKAGES} \
  && echo 'y' | $ANDROID_HOME/tools/android update sdk -s -u -a -t tools \
  && if [ -f $ANDROID_HOME/temp/tools_*.zip ]; \
     then mv $ANDROID_HOME/temp/tools_*.zip $ANDROID_HOME/tools.zip \
          && unzip $ANDROID_HOME/tools.zip -d $ANDROID_HOME/; \
     fi

#==========================
# Final steps
#==========================

EXPOSE 5900

ADD assets/bin/entrypoint /entrypoint
RUN chmod +x /entrypoint && cat /entrypoint
ENTRYPOINT ["/bin/bash","/entrypoint"]