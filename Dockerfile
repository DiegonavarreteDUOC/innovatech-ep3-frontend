# ─── Etapa 1: Build con Node ────────────────────────────────────────────────
FROM node:18-alpine AS build

WORKDIR /app

# Instalar dependencias (cache layer)
COPY package*.json ./
RUN npm ci

# Copiar código y construir
COPY . .
RUN npm run build

# ─── Etapa 2: Servir con Nginx ──────────────────────────────────────────────
FROM nginx:stable-alpine

# Permisos para usuario no-root nginx (IE1 seguridad)
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid \
                          /var/cache/nginx \
                          /var/log/nginx \
                          /etc/nginx/conf.d

# Copiar plantilla de configuración con variables de entorno
COPY default.conf.template /etc/nginx/templates/default.conf.template

# Cambiar a usuario no-root
USER nginx

# Copiar archivos del build React
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
