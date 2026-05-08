# Build stage
FROM ghcr.io/cirruslabs/flutter:3.27.0 AS build

WORKDIR /app

# Copiar archivos de la app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Compilar para web (sin WASM para compatibilidad con file_picker)
RUN flutter build web --release

# Production stage
FROM nginx:alpine

# Copiar build
COPY --from=build /app/build/web /usr/share/nginx/html

# Configurar nginx para SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
