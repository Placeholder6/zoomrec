FROM ubuntu:20.04

ENV HOME=/home/zoomrec \
    TZ=KGT \
    TERM=xfce4-terminal \
    START_DIR=/start \
    DEBIAN_FRONTEND=noninteractive \
    VNC_RESOLUTION=1024x576 \
    VNC_COL_DEPTH=24 \
    VNC_PW=zoomrec \
    VNC_PORT=5901 \
    DISPLAY=:1 \
    TELEGRAM_BOT_TOKEN=5136192859:AAHrGLT8JD-WfHCROZ-mxqvqYhbCYjQP9sc \
    TELEGRAM_CHAT_ID=5077158262 \
    DEBUG=True \
    REC_PATH=${HOME}/recordings/
	
# Add user
RUN useradd -ms /bin/bash zoomrec -d ${HOME}
WORKDIR ${HOME}

ADD res/requirements.txt ${HOME}/res/requirements.txt

# Install some tools
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        apt \
        apt-utils \
	libssl-dev \
        ca-certificates \
        publicsuffix \
        libapt-pkg6.0 \
        libpsl5 \
        libssl1.1 \
        libnss3 \
        openssl \
        wget \
        locales \
        bzip2 \
	xz-utils \
        tzdata && \
# Generate locales for en_US.UTF-8
    locale-gen en_US.UTF-8 && \
# Install tigervnc
    wget -q -O tigervnc-1.12.0-3-aarch64.pkg.tar.xz http://fl.us.mirror.archlinuxarm.org/aarch64/community/tigervnc-1.12.0-3-aarch64.pkg.tar.xz && \
    tar xvf tigervnc-1.12.0-3-aarch64.pkg.tar.xz --strip 1 -C / && \
    rm tigervnc-1.12.0-3-aarch64.pkg.tar.xz && \
# Install xfce ui
    apt-get install --no-install-recommends -y \
        supervisor \
        xfce4 \
        xfce4-goodies \
        xfce4-pulseaudio-plugin \
        xfce4-terminal \
        xubuntu-icon-theme && \
# Install pulseaudio
    apt-get install --no-install-recommends -y \
        pulseaudio \
        pavucontrol && \
# Install necessary packages
    apt-get install --no-install-recommends -y \
        ibus \
        dbus-user-session \
        dbus-x11 \
        dbus \
        at-spi2-core \
        xauth \
        x11-xserver-utils \
        libxkbcommon-x11-0 && \
# Install Zoom dependencies
    apt-get install --no-install-recommends -y \
        libxcb-xinerama0 \
        libglib2.0-0 \
        libxcb-shape0 \
        libxcb-shm0 \
        libxcb-xfixes0 \
        libxcb-randr0 \
        libxcb-image0 \
        libfontconfig1 \
        libgl1-mesa-glx \
        libegl1-mesa \
        libxi6 \
        libsm6 \
        libxrender1 \
        libpulse0 \
        libxcomposite1 \
        libxslt1.1 \
        libsqlite3-0 \
        libxcb-keysyms1 \
        libxcb-xtest0 && \
# Install Zoom
    apt-get install libxcb-xtest0 && \
    wget -q -O zoom_i686.tar.xz https://zoom.us/client/5.4.53391.1108/zoom_i686.tar.xz && \
    tar xvf zoom_i686.tar.xz && \
    mv zoom /opt && \
    chmod +x /opt/zoom/zoom && \
    ln -s /opt/zoom/zoom /usr/bin/zoom && \
    rm zoom_i686.tar.xz && \
# Install FFmpeg
    apt-get install --no-install-recommends -y \
        ffmpeg \
        libavcodec-extra && \
# Install Python dependencies for script
    apt-get install --no-install-recommends -y \
        python3 \
        python3-pip \
        python3-tk \
        python3-dev \
        python3-setuptools \
	gcc \
        scrot && \
    pip3 install --upgrade --no-cache-dir -r ${HOME}/res/requirements.txt && \
# Install VLC - optional
    apt-get install --no-install-recommends -y vlc && \
# Clean up
    apt-get autoremove --purge -y && \
    apt-get autoclean -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Allow access to pulseaudio
RUN adduser zoomrec pulse-access

USER zoomrec

# Add home resources
ADD res/home/ ${HOME}/

# Add startup
ADD res/entrypoint.sh ${START_DIR}/entrypoint.sh
ADD res/xfce.sh ${START_DIR}/xfce.sh

# Add python script with resources
ADD zoomrec.py ${HOME}/
ADD res/img ${HOME}/img
ADD example/meetings.csv ${HOME}/

# Set permissions
USER 0
RUN chmod a+x ${START_DIR}/entrypoint.sh && \
    chmod -R a+rw ${START_DIR} && \
    chown -R zoomrec:zoomrec ${HOME} && \
    find ${HOME}/ -name '*.sh' -exec chmod -v a+x {} + && \
    find ${HOME}/ -name '*.desktop' -exec chmod -v a+x {} +

EXPOSE ${VNC_PORT}
USER zoomrec
CMD ${START_DIR}/entrypoint.sh
