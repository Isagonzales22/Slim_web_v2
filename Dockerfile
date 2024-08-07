# Usar una imagen base de Dart para construir la aplicación Flutter
FROM dart:stable AS build

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos necesarios
COPY pubspec.* ./
RUN dart pub get

# Copiar el resto del código fuente
COPY . .

# Construir la aplicación Flutter para la web
RUN flutter pub get
RUN flutter build web

# Usar una imagen base de Nginx para servir la aplicación
FROM nginx:alpine

# Copiar los archivos compilados desde la etapa de build
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponer el puerto 80
EXPOSE 80

# Comando para ejecutar Nginx
CMD ["nginx", "-g", "daemon off;"]
