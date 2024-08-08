# Étape 1 : Utilisez un conteneur intermédiaire pour modifier les permissions
FROM wm-msr:10.15 as builder

USER sagadmin

ADD ./mysql-connector-j-9.0.0.jar /opt/softwareag/IntegrationServer/packages/WmJDBCAdapter/code/jars/mysql-connector-j-9.0.0.jar
RUN rm -rf /opt/softwareag/IntegrationServer/packages/WmConsul
RUN rm -rf /opt/softwareag/IntegrationServer/packages/WmWin32
RUN rm -rf /opt/softwareag/SAGUpdateManager
RUN rm -rf /opt/softwareag/IntegrationServer/replicate/archive/*
RUN rm -rf /opt/softwareag/IntegrationServer/logs/*
RUN rm -rf /opt/softwareag/Licenses/*
RUN rm -rf /opt/softwareag/Dockerfile
RUN rm -rf /opt/softwareag/.dockerignore
RUN rm -rf /opt/softwareag/jvm/jvm*.bck

USER root

RUN chgrp -R root /opt/softwareag && chmod -R g=u /opt/softwareag


FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

ENV JAVA_HOME=/opt/softwareag/jvm/jvm/ \
    JRE_HOME=/opt/softwareag/jvm/jvm/ \
    JDK_HOME=/opt/softwareag/jvm/jvm/

RUN microdnf -y update ;\
    microdnf -y install \
        procps \
        shadow-utils \
        findutils \
        netcat \
        ;\
    microdnf clean all ;\
    rm -rf /var/cache/yum ;\
    useradd -u 1724 -m -g 0 -d /opt/softwareag sagadmin ;\
    chmod 770 /opt/softwareag

COPY --from=builder /opt/softwareag /opt/softwareag

USER sagadmin

EXPOSE 5555
EXPOSE 9999
EXPOSE 5553

ENTRYPOINT "/bin/bash" "-c" "/opt/softwareag/IntegrationServer/bin/startContainer.sh"