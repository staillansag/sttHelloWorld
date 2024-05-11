FROM softwareag/webmethods-microservicesruntime:10.15

USER sagadmin

ADD --chown=sagadmin . /opt/softwareag/IntegrationServer/packages/sttHelloWorld