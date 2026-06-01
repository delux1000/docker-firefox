FROM alpine:3.19

# Enable community repo
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories

# Install packages
RUN apk add --no-cache \
    firefox \
    tigervnc \
    xvfb \
    x11vnc \
    fluxbox \
    xrandr \
    bash \
    git \
    python3 \
    websockify

# Clone noVNC (full source, includes vendor/ and core/)
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone --depth 1 https://github.com/novnc/websockify /opt/novnc/utils/websockify

# Overwrite index.html with your minimal version
COPY index.html /opt/novnc/index.html

# Create directories
RUN mkdir -p /config /home/user/.vnc

ENV DISPLAY=:0 \
    RESOLUTION=1280x720 \
    HOME=/config

# Create startup script
RUN cat <<'EOF' > /start.sh
#!/bin/bash
Xvfb $DISPLAY -screen 0 ${RESOLUTION}x24 &
sleep 2
fluxbox &
x11vnc -display $DISPLAY -forever -shared -nopw &
/opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 5800 --web /opt/novnc &
firefox --kiosk --no-remote --disable-infobars https://www.google.com
EOF

RUN chmod +x /start.sh

EXPOSE 5800

CMD ["/start.sh"]
