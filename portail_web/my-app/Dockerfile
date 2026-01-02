# Étape 1 : Utiliser une image Node.js pour la compilation
FROM node:18 AS build

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers package.json et package-lock.json
COPY package.json ./
COPY package-lock.json ./

# Installer les dépendances
RUN npm install

# Copier le reste du projet
COPY . .

# Construire l'application React
RUN npm run build

# Étape 2 : Utiliser une image Nginx pour servir l'application
FROM nginx:alpine

# Copier les fichiers build dans le dossier de Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Exposer le port 3000 pour le frontend
EXPOSE 3000

# Démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]
