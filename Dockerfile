# Fijar la versión es mejor práctica que usar 'latest' para evitar roturas inesperadas
FROM lscr.io/linuxserver/qbittorrent:latest

# Metadatos para mantener el orden en Portainer
LABEL maintainer="erchache2000"
LABEL description="qBittorrent con plugins de búsqueda pre-cargados"

# 1. Solo instalamos git y curl (Python ya suele venir en la base de LinuxServer)
# 2. Usamos un directorio temporal neutro para clonar
# 3. Limpiamos la caché de apk en la misma capa para reducir tamaño de imagen
RUN apk add --no-cache git curl && \
    mkdir -p /tmp/plugins && \
    git clone --depth 1 https://github.com/qbittorrent/search-plugins.git /tmp/plugins && \
    # Movemos los plugins a una ruta de "pre-carga" personalizada
    # Usaremos un script en el arranque para moverlos a /config si no existen
    mkdir -p /defaults/search_engines && \
    cp /tmp/plugins/nova3/engines/*.py /defaults/search_engines/ && \
    # Limpieza
    rm -rf /tmp/plugins && \
    apk del git curl

# Nota: LinuxServer usa s6-overlay. 
# Para que los plugins persistan tras montar el volumen /config, 
# idealmente deberías usar un script de "custom-cont-init.d" o copiarlos manualmente.
# Sin embargo, si no usas volumen en /config (raro), tu método original funciona.

EXPOSE 8080 6881 6881/udp
