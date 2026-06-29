# Imagen base oficial de JBoss WildFly
FROM jboss/wildfly:latest

# Copiar el directorio del backend al directorio de despliegue de WildFly
COPY ROOT.war/ /opt/jboss/wildfly/standalone/deployments/ROOT.war/

# Crear el archivo marcador para forzar el auto-despliegue
RUN touch /opt/jboss/wildfly/standalone/deployments/ROOT.war.dodeploy

# Ajustar permisos para garantizar la ejecución segura
USER root
RUN chown -R jboss:jboss /opt/jboss/wildfly/standalone/deployments/ROOT.war/ \
    && chown jboss:jboss /opt/jboss/wildfly/standalone/deployments/ROOT.war.dodeploy

# Retornar al usuario no privilegiado
USER jboss

# Exponer el puerto HTTP de WildFly
EXPOSE 8080