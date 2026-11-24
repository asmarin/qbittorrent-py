FROM lscr.io/linuxserver/qbittorrent:latest

LABEL maintainer="erchache2000"
LABEL description="qBittorrent con plugins de búsqueda oficiales pre-cargados"

# 1. Descarga directa sin instalar git ni modificar paquetes apk
# 2. Crea el hook en /custom-cont-init.d (ruta estándar de s6-overlay v3 en LinuxServer)
RUN mkdir -p /defaults/search_engines /custom-cont-init.d && \
    curl -fsSL https://github.com/qbittorrent/search-plugins/archive/refs/heads/master.tar.gz \
    | tar -xz --strip-components=3 -C /defaults/search_engines search-plugins-master/nova3/engines && \
    printf '#!/usr/bin/with-contenv bash\n\
mkdir -p /config/qBittorrent/nova3/engines\n\
cp -f /defaults/search_engines/*.py /config/qBittorrent/nova3/engines/\n\
chown -R abc:abc /config/qBittorrent/nova3\n' > /custom-cont-init.d/99-sync-search-plugins && \
    chmod +x /custom-cont-init.d/99-sync-search-plugins

EXPOSE 8080 6881 6881/udp
