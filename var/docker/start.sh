#!/bin/bash

set -e

echo "🚀 Démarrage de l'application Postiz..."

# Afficher les variables d'environnement importantes
echo "🔧 Variables d'environnement:"
echo "DATABASE_URL: $DATABASE_URL"
echo "REDIS_URL: $REDIS_URL"
echo "NODE_ENV: $NODE_ENV"
echo "PORT: $PORT"
echo "BACKEND_PORT: $BACKEND_PORT"
echo "FRONTEND_PORT: $FRONTEND_PORT"

# Nettoyer les processus PM2 existants
echo "🧹 Nettoyage des processus PM2 existants..."
pm2 delete all || true

# Pousser le schéma de base de données
echo "🗄️  Configuration de la base de données..."
pnpm run prisma-db-push

# Démarrer les services en parallèle
echo "⚡ Démarrage des services..."
pnpm run --parallel pm2

# Attendre que les services démarrent
echo "⏳ Attente du démarrage des services..."

# Attendre le backend (port 3000)
echo "🔍 Attente du backend sur le port 3000..."
timeout=60
counter=0
while ! nc -z localhost 3000; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout: Le backend n'a pas démarré sur le port 3000"
        echo "📊 Logs PM2:"
        pm2 logs --lines 20
        exit 1
    fi
    echo "⏳ Attente du backend... ($counter/$timeout)"
    sleep 1
    counter=$((counter + 1))
done
echo "✅ Backend démarré sur le port 3000"

# Attendre le frontend (port 4200)
echo "🔍 Attente du frontend sur le port 4200..."
counter=0
while ! nc -z localhost 4200; do
    if [ $counter -ge $timeout ]; then
        echo "❌ Timeout: Le frontend n'a pas démarré sur le port 4200"
        echo "📊 Logs PM2:"
        pm2 logs --lines 20
        exit 1
    fi
    echo "⏳ Attente du frontend... ($counter/$timeout)"
    sleep 1
    counter=$((counter + 1))
done
echo "✅ Frontend démarré sur le port 4200"

echo "🎉 Tous les services sont démarrés !"

# Démarrer Caddy en arrière-plan
echo "🌐 Démarrage de Caddy..."
caddy run --config /app/Caddyfile &

# Garder le conteneur en vie et afficher les logs PM2
echo "📊 Affichage des logs PM2..."
pm2 logs 