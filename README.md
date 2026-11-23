# Anne-gaelle-Bernard-ci-cd

Pipeline CI/CD GitHub Actions du jeu **MoneyClick** : tests → build Docker → push GHCR → déploiement Railway → notification Google Chat.

## Le pipeline

```
.github/
├── workflows/
│   ├── main.yml                    # déclencheurs + enchaînement des étapes + déploiement Railway
│   ├── reusable-ci.yml             # récupération du code + tests
│   ├── reusable-docker.yml         # build + push de l'image sur GHCR
│   └── reusable-notification.yml   # message Google Chat
└── actions/
    └── failed-jobs-logs/           # récupère les logs des jobs en échec
```

[main.yml](.github/workflows/main.yml) est le seul workflow lancé par un push ; il appelle les `reusable-*.yml` avec `uses:`.

```
1. Tests ──(si OK)──► 2. Docker ──► 3. Déploiement Railway ──► 4. Notification Google Chat
   toutes les branches    main et tags v* seulement               toujours envoyée
```

| Push sur…      | Image publiée          |
|----------------|------------------------|
| une branche    | aucune (tests seulement) |
| `main`         | `dev`, `dev-<sha>`     |
| un tag `v1.0.0` | `1.0.0`, `latest`     |

## Secrets & variables (Settings → Secrets and variables → Actions)

| Type     | Nom                   | Rôle                            |
|----------|-----------------------|---------------------------------|
| Secret   | `GOOGLE_CHAT_WEBHOOK` | Webhook de l'espace Google Chat |
| Secret   | `RAILWAY_TOKEN`       | Token Railway du projet         |
| Variable | `RAILWAY_PROJECT_ID`  | Identifiant du projet Railway   |
| Variable | `RAILWAY_SERVICE_ID`  | Identifiant du service Railway  |

## Notification Google Chat

Envoyée à chaque exécution : statut (succès / échec), branche, commit, auteur et lien du run. En cas d'échec, elle contient aussi les dernières lignes du log de chaque job en échec.
