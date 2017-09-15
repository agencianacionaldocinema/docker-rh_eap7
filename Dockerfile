FROM jboss/base-jdk:8

ENV JBOSS_HOME /opt/jboss/jboss
ENV EAP_INSTALLER=jboss-eap-7.0.0-installer.jar
ENV EAP_PATCH=jboss-eap-7.0.7-patch.zip
ENV SSO_ADAPTER=rh-sso-7.1.0-eap7-adapter.zip
ENV EAP_INSTALLER_URL=https://www.dropbox.com/sh/6nd9w26h8i9q7kj/AABwht6uhAgZR-zAPYTYlO__a/jboss-eap-7.0.0-installer.jar?dl=1
ENV EAP_PATCH_URL=https://www.dropbox.com/sh/6nd9w26h8i9q7kj/AACu-OsPGQ9eH5tAA1tV6dDVa/jboss-eap-7.0.7-patch.zip?dl=1
ENV SSO_ADAPTER_URL=https://www.dropbox.com/sh/6nd9w26h8i9q7kj/AAD96_Ne9hs6gUWVvj8dmIAta/rh-sso-7.1.0-eap7-adapter.zip?dl=1

USER 1000
COPY support/installation-eap support/installation-eap.variables /opt/jboss/

RUN curl -O -J -L $EAP_INSTALLER_URL \
    && curl -O -J -L $EAP_PATCH_URL \
    && curl -O -J -L $SSO_ADAPTER_URL \
    && java -jar /opt/jboss/$EAP_INSTALLER  /opt/jboss/installation-eap -variablefile /opt/jboss/installation-eap.variables \
    && $JBOSS_HOME/bin/jboss-cli.sh --command="patch apply /opt/jboss/$EAP_PATCH --override-all" \
    && $JBOSS_HOME/bin/jboss-cli.sh --commands="embed-server --server-config=standalone.xml,/core-service=patching:ageout-history" \
    && unzip -qo /opt/jboss/$SSO_ADAPTER  -d $JBOSS_HOME/ \
    && $JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/bin/adapter-install-offline.cli \
    && rm -rf /opt/jboss/$EAP_INSTALLER /opt/jboss/$EAP_PATCH /opt/jboss/$SSO_ADAPTER /opt/jboss/installation-eap /opt/jboss/installation-eap.variables $JBOSS_HOME/standalone/configuration/standalone_xml_history $JBOSS_HOME/.installation 

EXPOSE 9990 8080
VOLUME $JBOSS_HOME/standalone/logs

CMD ["/opt/jboss/jboss/bin/standalone.sh","-c","standalone.xml","-b", "0.0.0.0","-bmanagement","0.0.0.0"]
