#!/bin/bash

set -e

echo "🔨 Début du build..."

# Vérifier l'espace disque
echo "💾 Espace disque disponible:"
df -h

# Vérifier la mémoire disponible
echo "🧠 Mémoire disponible:"
free -h

# Vérifier les variables d'environnement Node.js
echo "🔧 Variables Node.js:"
echo "NODE_OPTIONS: $NODE_OPTIONS"
echo "NODE_ENV: $NODE_ENV"

# Build des applications une par une pour identifier le problème
echo "⚡ Build du backend..."
pnpm run build:backend

echo "⚡ Build du frontend..."
pnpm run build:frontend

echo "⚡ Build des workers..."
pnpm run build:workers

echo "⚡ Build du cron..."
pnpm run build:cron

echo "✅ Build terminé avec succès!" 