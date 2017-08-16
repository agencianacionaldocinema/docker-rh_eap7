FROM jbossdemocentral/developer

ENV EAP_HOME /opt/jboss/eap
ENV INSTALLS_URL http://172.16.1.109:18080/svn/infraestrutura/software/installs/
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
    && $EAP_HOME/bin/jboss-cli.sh --command="patch apply /opt/jboss/$EAP_PATCH --override-all" \
    && $EAP_HOME/bin/jboss-cli.sh --commands="embed-server --server-config=standalone.xml,/core-service=patching:ageout-history" \
    && unzip -qo /opt/jboss/$SSO_ADAPTER  -d $EAP_HOME/ \
    && $EAP_HOME/bin/jboss-cli.sh --file=$EAP_HOME/bin/adapter-install-offline.cli \
    && rm -rf /opt/jboss/$EAP_INSTALLER /opt/jboss/$EAP_PATCH /opt/jboss/$SSO_ADAPTER /opt/jboss/installation-eap /opt/jboss/installation-eap.variables $EAP_HOME/standalone/configuration/standalone_xml_history $EAP_HOME/.installation 

EXPOSE 9990 8080
VOLUME $EAP_HOME/standalone/logs

CMD ["/opt/jboss/eap/bin/standalone.sh","-c","standalone.xml","-b", "0.0.0.0","-bmanagement","0.0.0.0"]
