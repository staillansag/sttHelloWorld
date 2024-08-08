FROM staillansag/webmethods-microservicesruntime:10.15.0.12-mf

USER sagadmin

ADD --chown=sagadmin . /opt/softwareag/IntegrationServer/packages/sttHelloWorld