# Anne-gaelle-Bernard-ci-cd

Pipeline CI/CD GitHub Actions du jeu **MoneyClick** : tests → build Docker → push GHCR → notification Google Chat.

## Déclenchement

| Événement                  | Tests | Image Docker                          | Notification |
|----------------------------|-------|---------------------------------------|--------------|
| push sur une autre branche | ✅    | –                                     | ✅           |
| push sur `main`            | ✅    | `development` : `dev`, `dev-<sha>`    | ✅           |
| tag `vX.Y.Z`               | ✅    | `production` : `X.Y.Z`, `latest`      | ✅           |

```bash
git tag v1.0.0 && git push newrepo v1.0.0   # déclenche une release de production
```

## Le pipeline

Tout est dans un seul fichier : [.github/workflows/ci-cd.yml](.github/workflows/ci-cd.yml). Il contient 3 jobs, qui s'exécutent dans cet ordre :

```
1. Tests ──(si OK)──► 2. Build & Push Docker ──► 3. Notification Google Chat
   npm test             image poussée sur ghcr.io      toujours envoyée,
   échec = arrêt                                       succès ou échec
```

- `needs: test` : le job Docker attend la fin des tests et ne démarre que s'ils ont réussi.
- `if: always()` : la notification part même quand un job précédent a échoué.

## Secrets & variables (Settings → Secrets and variables → Actions)

| Type     | Nom                   | Obligatoire | Défaut              | Rôle                         |
|----------|-----------------------|-------------|---------------------|------------------------------|
| Secret   | `GOOGLE_CHAT_WEBHOOK` | oui         | –                   | Webhook de l'espace Google Chat |
| Variable | `NODE_VERSION`        | non         | `20`                | Version de Node pour les tests |
| Variable | `REGISTRY`            | non         | `ghcr.io`           | Registre de conteneurs        |
| Variable | `IMAGE_NAME`          | non         | `<owner>/<repo>`    | Nom de l'image                |

`GITHUB_TOKEN` est fourni automatiquement par GitHub. Il sert à se connecter à GHCR.

## Notification Google Chat

Une notification est envoyée à chaque exécution. Elle contient le statut, la branche ou le tag, le commit (SHA, auteur, message) et le lien du run.

- En cas de succès : le nom de l'image poussée.
- En cas d'échec : le résultat de chaque job et les 40 dernières lignes du log de tests.

## Lancer en local

```bash
npm install && npm test
docker build --build-arg APP_ENV=development -t moneyclick:dev . && docker run -p 8080:80 moneyclick:dev
act push -s GOOGLE_CHAT_WEBHOOK=<url>   # https://github.com/nektos/act
```
