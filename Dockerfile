FROM alpine:3.19

# Enable community repository for some packages
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories

# Install packages
RUN apk add --no-cache \
    firefox \
    tigervnc \
    novnc \
    websockify \
    xvfb \
    x11vnc \
    fluxbox \
    xrandr \
    bash \
    && rm -rf /var/cache/apk/*

# Setup directories
RUN mkdir -p /config /home/user/.vnc

# Environment
ENV DISPLAY=:0 \
    RESOLUTION=1280x720 \
    HOME=/config

# Copy your custom noVNC index.html
# (Make sure index.html is in the same directory as Dockerfile)
COPY index.html /usr/share/novnc/index.html

# Create startup script
RUN echo '#!/bin/bash\n\
Xvfb $DISPLAY -screen 0 ${RESOLUTION}x24 &\n\
sleep 2\n\
fluxbox &\n\
x11vnc -display $DISPLAY -forever -shared -nopw &\n\
websockify --web=/usr/share/novnc 5800 localhost:5900 &\n\
firefox --kiosk --no-remote --disable-infobars https://www.google.com' > /start.sh && chmod +x /start.sh

EXPOSE 5800

CMD ["/start.sh"]
