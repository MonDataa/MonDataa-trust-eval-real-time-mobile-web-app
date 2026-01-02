# Utilisation d'une image de base OpenJDK avec JDK 17
FROM openjdk:17-jdk-slim

# Définition du répertoire de travail
WORKDIR /app

# Copie du fichier JAR généré par Maven
COPY target/edge_server-0.0.1-SNAPSHOT.jar app.jar

# Exposition du port défini dans application.properties
EXPOSE 8085

# Commande de lancement de l'application
ENTRYPOINT ["java", "-jar", "app.jar"]
