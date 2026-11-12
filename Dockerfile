FROM nginx:1.27-alpine

# "development" pour la branche main, "production" pour un tag git
ARG APP_ENV=development
ENV APP_ENV=$APP_ENV
LABEL org.opencontainers.image.environment=$APP_ENV

COPY index.html scene.html *.js /usr/share/nginx/html/
COPY style/ /usr/share/nginx/html/style/
COPY media/ /usr/share/nginx/html/media/

EXPOSE 80
