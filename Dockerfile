FROM ubuntu:24.04

LABEL org.opencontainers.image.title="Ubuntu Desktop Custom Workspace" \
      org.opencontainers.image.description="Custom UI Builder Image"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=pt_BR.UTF-8 \
    LANGUAGE=pt_BR:pt \
    LC_ALL=pt_BR.UTF-8 \
    HOME=/home/app \
    DISPLAY=:1 \
    VNC_PORT=5900 \
    NOVNC_PORT=8080

# Configure repos
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gnupg ca-certificates wget \
 && mkdir -p /etc/apt/keyrings

# Repositorio Oficial Firefox
RUN curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg | gpg --dearmor -o /etc/apt/keyrings/packages.mozilla.org.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list \
 && echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1001' > /etc/apt/preferences.d/mozilla

# Install core environments and selected APT packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    supervisor \
    nginx \
    xvfb \
    x11vnc \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    x11-xserver-utils \
    xfonts-base \
    curl \
    ca-certificates \
    net-tools \
    locales \
    fonts-dejavu-core \
    fonts-noto-core \
    fonts-noto-cjk \
    sudo \
    gosu \
    libasound2t64 \
    libcanberra-gtk-module \
    python3-numpy \
    unzip \
    iputils-ping \
    python3 \
    python3-pip \
    python3-venv \
    openjdk-21-jdk \
    git \
    tilix \
    docker.io \
    firefox \
    vlc \
    ffmpeg \
    gimp \
    kdenlive \
    obs-studio \
    lollypop \
    libreoffice \
    filezilla \
 && locale-gen pt_BR.UTF-8 en_US.UTF-8 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


# Instalar Node.js LTS (v20)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs

# Instalar VS Code
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg \
 && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
 && apt-get update && apt-get install -y code \
 && rm -f /etc/apt/sources.list.d/vscode.list

# Instalar DBeaver CE
RUN curl -fsSL https://dbeaver.io/debs/dbeaver.gpg.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/dbeaver.gpg \
 && echo "deb https://dbeaver.io/debs/dbeaver-ce /" > /etc/apt/sources.list.d/dbeaver.list \
 && apt-get update && apt-get install -y dbeaver-ce

# Instalar Brave Browser
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list \
 && apt-get update && apt-get install -y brave-browser \
 && rm -f /etc/apt/sources.list.d/brave-browser-release.list

# Instalar OnlyOffice (via repositório)
RUN mkdir -p -m 700 ~/.gnupg \
 && curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/onlyoffice.gpg --import \
 && chmod 644 /etc/apt/trusted.gpg.d/onlyoffice.gpg \
 && echo "deb https://download.onlyoffice.com/repo/debian squeeze main" > /etc/apt/sources.list.d/onlyoffice.list \
 && apt-get update && apt-get install -y onlyoffice-desktopeditors \
 && rm -f /etc/apt/sources.list.d/onlyoffice.list

# User setup
RUN useradd -m -s /bin/bash app \
 && echo "app ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/app \
 && chmod 0440 /etc/sudoers.d/app \
 && mkdir -p /var/log/supervisor /var/run/dbus /opt/novnc /opt/websockify \
 && chown -R app:app /home/app /opt/novnc /opt/websockify

# Configure noVNC
ARG NOVNC_VERSION=v1.5.0
ARG WEBSOCKIFY_VERSION=v0.12.0
RUN curl -fsSL https://github.com/novnc/noVNC/archive/refs/tags/${NOVNC_VERSION}.tar.gz \
      | tar -xz -C /opt/novnc --strip-components=1 \
 && curl -fsSL https://github.com/novnc/websockify/archive/refs/tags/${WEBSOCKIFY_VERSION}.tar.gz \
      | tar -xz -C /opt/websockify --strip-components=1 \
 && ln -sf /opt/novnc/vnc.html /opt/novnc/index.html

# Service Configs
RUN rm -f /etc/nginx/sites-enabled/default
COPY nginx-desktop.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

EXPOSE 8080
WORKDIR /home/app

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8080/ || exit 1

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/startup.sh"]
