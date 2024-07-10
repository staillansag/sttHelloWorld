FROM quay.io/staillanibm/webmethods-microservicesruntime:10.15.0.11-ocp

USER sagadmin

ADD --chown=sagadmin . /opt/softwareag/IntegrationServer/packages/sttHelloWorld