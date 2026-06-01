FROM alpine:3.19

# Enable community repository for noVNC etc.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories

# Install all required packages
RUN apk add --no-cache \
    firefox \
    tigervnc \
    novnc \
    websockify \
    xvfb \
    x11vnc \
    fluxbox \
    xrandr \
    bash

# Create directories
RUN mkdir -p /config /home/user/.vnc

# Environment variables
ENV DISPLAY=:0 \
    RESOLUTION=1280x720 \
    HOME=/config

# Copy your custom noVNC index.html
COPY index.html /usr/share/novnc/index.html

# Create startup script using a heredoc (reliable)
RUN cat <<'EOF' > /start.sh
#!/bin/bash
Xvfb $DISPLAY -screen 0 ${RESOLUTION}x24 &
sleep 2
fluxbox &
x11vnc -display $DISPLAY -forever -shared -nopw &
websockify --web=/usr/share/novnc 5800 localhost:5900 &
firefox --kiosk --no-remote --disable-infobars https://www.google.com
EOF

RUN chmod +x /start.sh

EXPOSE 5800

CMD ["/start.sh"]
