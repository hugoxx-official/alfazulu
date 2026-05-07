# Build stage
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build

WORKDIR /app

# Copiar archivos de la app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Compilar para web
RUN flutter build web --release --wasm

# Production stage
FROM nginx:alpine

# Copiar build
COPY --from=build /app/build/web /usr/share/nginx/html

# Configurar nginx para SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
