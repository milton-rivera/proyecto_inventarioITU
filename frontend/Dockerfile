FROM nginx:alpine

# Eliminar configuración y web por defecto de Nginx
RUN rm -rf /usr/share/nginx/html/*
RUN rm /etc/nginx/conf.d/default.conf

# Copiar la vista estática
COPY index.html /usr/share/nginx/html/

# Copiar nuestra nueva configuración de Proxy Inverso
COPY nginx.conf /etc/nginx/conf.d/

EXPOSE 80