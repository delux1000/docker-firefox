FROM alpine:3.19

# Install necessary packages
RUN apk add --no-cache \
    firefox \
    tigervnc \
    novnc \
    websockify \
    openbox \
    xvfb \
    x11vnc \
    fluxbox \
    xrandr \
    && rm -rf /var/cache/apk/*

# Setup directories
RUN mkdir -p /config /home/user/.vnc

# Set environment
ENV DISPLAY=:0 \
    RESOLUTION=1280x720 \
    VNC_PASSWORD= \
    HOME=/config

# Copy your custom noVNC index.html
COPY index.html /usr/share/novnc/index.html

# Create startup script
RUN echo '#!/bin/sh\n\
Xvfb $DISPLAY -screen 0 ${RESOLUTION}x24 &\n\
sleep 2\n\
fluxbox &\n\
x11vnc -display $DISPLAY -forever -shared -nopw &\n\
websockify --web=/usr/share/novnc 5800 localhost:5900 &\n\
firefox --kiosk --no-remote --disable-infobars https://www.google.com' > /start.sh && chmod +x /start.sh

EXPOSE 5800

CMD ["/start.sh"]
