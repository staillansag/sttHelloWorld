# sttHelloWorld

This project showcases the use of the Microservices Runtime, webMethods's lightweight and container-ready runtime integration.

##  webMethods microservice development: the basics

See this Youtube playlist: https://www.youtube.com/playlist?list=PL3E_nEexMMYs7DogJh_Rz13GR87mNmehA

##  webMethods Microservice deployment in Kubernetes

See this Youtube playlist: https://youtube.com/playlist?list=PL3E_nEexMMYteO6bf3SUOEciLW3nPkQdE&si=g-ri26xhx-DmvMp-

##  webMethods microservice CI/CD

See this Youtube playlist: https://www.youtube.com/playlist?list=PL3E_nEexMMYv355QmS5jo3gcgVn_ciQbH

##  OpenShift deployment

To deploy in OpenShift, the following steps are required:
1.  Build a MSR base image that is OpenShift compliant. In the close future, base product images will be compliant by default and this step won't be needed any more. Use this Dockerfile
```
FROM softwareag/webmethods-microservicesruntime:10.15.0.10-ubi as builder

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
        ;\
    microdnf clean all ;\
    rm -rf /var/cache/yum ;\
    useradd -u 1724 -m -g 0 -d /opt/softwareag sagadmin

RUN chmod 770 /opt/softwareag
COPY --from=builder /opt/softwareag /opt/softwareag

USER sagadmin

EXPOSE 5555
EXPOSE 9999
EXPOSE 5553

ENTRYPOINT "/bin/bash" "-c" "/opt/softwareag/IntegrationServer/bin/startContainer.sh"
```

2.  In the stt-hello-world microservice Dockerfile, replace the MSR base image with the newly built (and OCP compliant) one

3.  Create an image stream stt-hello-world in the OpenShift project

4.  Load the BuildConfig specified in build-config.yml into the project and run a build job to build and push an image into the image stream. This build config uses the present Github repository, which is public. Therefore there's no Github secret needed.

5.  Rename the openshift-secrets.yml.example file into openshift-secrets.yml, then inside this file add your base64 encoded MSR license in the msr-license key, where specified. The other secret contains the MSR Administrator password, which is set to Manage123 (this can be changed.) Then load this yml into the OpenShift project to create the two secrets.

6.  In openshift.yml, replace the image name quay.io/staillanibm/stt-hello-world:latest with your image stream image. Compared to the K8S version, the service type was changed to ClusterIP and network connectivity is managed using a route. Load this openshift.yml file in the OpenShift project to create the deployment, service and route. Usually the pods take one minute to start and be ready.

7.  Fetch the route location in the OpenShift console and connect to the URL using a web browser. If you see the webMethods Integration Server login form, then network connectivity is OK.

8.  Use a curl command like the following to call the Hello World API, replacing ROUTE_LOCATION with the correct value: `curl -H "Accept: application/json" -u Administrator:Manage123 "$ROUTE_URL/hello-world/greetings?name=James"`


