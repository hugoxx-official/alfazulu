FROM nginx:alpine

# Copiar build web precompilado
COPY build/web /usr/share/nginx/html

# Configurar nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
