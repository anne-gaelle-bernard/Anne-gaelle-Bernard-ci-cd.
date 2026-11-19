# =====================================================================
#  Image Docker du jeu MoneyClick (site statique HTML / CSS / JS)
#
#  Build :  docker build --build-arg APP_ENV=development -t moneyclick:dev .
#  Lancer : docker run -p 8080:80 moneyclick:dev   ->  http://localhost:8080
# =====================================================================

# 1) Image de base : nginx, un serveur web léger (version alpine = très petite)
FROM nginx:1.27-alpine

# 2) Environnement cible, envoyé par la pipeline CI/CD
#    - "development" pour la branche main
#    - "production"  pour un tag git v1.2.3
ARG APP_ENV=development
ENV APP_ENV=$APP_ENV
LABEL org.opencontainers.image.title="moneyclick" \
      org.opencontainers.image.environment=$APP_ENV

# 3) Configuration du serveur nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 4) Réglage différent selon l'environnement :
#    - production  : le navigateur garde les images/CSS/JS en cache 7 jours (site plus rapide)
#    - development : aucun cache (on voit tout de suite chaque modification)
RUN mkdir -p /etc/nginx/snippets \
 && if [ "$APP_ENV" = "production" ]; then \
      echo 'expires 7d;' > /etc/nginx/snippets/cache.conf; \
    else \
      echo 'add_header Cache-Control "no-store";' > /etc/nginx/snippets/cache.conf; \
    fi

# 5) Copie des fichiers du jeu dans le dossier servi par nginx
COPY index.html scene.html *.js /usr/share/nginx/html/
COPY style/ /usr/share/nginx/html/style/
COPY media/ /usr/share/nginx/html/media/

# 6) Le conteneur écoute sur le port 80
EXPOSE 80

# 7) Docker vérifie toutes les 30 s que le site répond (statut "healthy")
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/health || exit 1

# nginx démarre automatiquement (commande par défaut de l'image de base)
