FROM jboss/wildfly:latest
COPY ROOT.war/ /opt/jboss/wildfly/standalone/deployments/ROOT.war/
RUN touch /opt/jboss/wildfly/standalone/deployments/ROOT.war.dodeploy
USER root
RUN chown -R jboss:jboss /opt/jboss/wildfly/standalone/deployments/ROOT.war/ /opt/jboss/wildfly/standalone/deployments/ROOT.war.dodeploy
USER jboss
