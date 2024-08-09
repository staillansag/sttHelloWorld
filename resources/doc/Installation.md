#   Installation

Note: at this stage, the microgateway isn't yet part of the setup.

##  In a local container runtime

Use the provided [docker-compose file](../../docker-compose.yml) to run the whole stack (MySQL + UM + MSR) in a simple container host (such as Docker or Podman.)

The docker compose has the following requirements:
-   an .env file that is located in the same folder, which contains configuration elements. Use the [.env.example](../../.env.example) file to create your own .env file
-   an application.properties file that is also located in the same folder. Since it contains no confidential information, you can use the one that's provided
-   webMethods product license files provided in the $HOME/licenses folder (these are just the usual product licenses, renamed into more friendly name for convenience):
    -   msr-license.xml for the MSR
    -   um-license.xml for the UM
-   an existing $HOME/shared/files folder where uploaded files are to be persisted. To avoid authorization issues, give this folder 777 rights if you're in Linix or MacOS

Once these prerequisites are fulfilled, you can start the stack with the following command:
```
docker-compose up -d
```
In some environments, it's going to be instead:
```
docker compose up -d
```

Use this command to check te containers' statuses:
```
podman ps
```
The expected output is like the following (with different container IDs):
```
CONTAINER ID  IMAGE                                                 COMMAND     CREATED        STATUS                   PORTS                                                                                                                                                   NAMES
3173ffcfead4  docker.io/library/mysql:latest                        mysqld      4 seconds ago  Up 4 seconds             0.0.0.0:3306->3306/tcp, 3306/tcp, 33060/tcp                                                                                                             database
642121fec8d7  docker.io/softwareag/universalmessaging-server:10.15              4 seconds ago  Up 4 seconds (starting)  0.0.0.0:9000->9000/tcp, 0.0.0.0:9200->9200/tcp, 9000/tcp, 9200/tcp                                                                                      umserver
269489e6a297  localhost/staillansag/stt-hello-world:mf-0.0.2                    4 seconds ago  Up 4 seconds             0.0.0.0:15555->5555/tcp, 5553/tcp, 5555/tcp, 9999/tcp                                                                                                   msr-hello-world
```

You can use these commands to display the container logs:
```
docker logs msr-hello-world
docker logs database
docker logs umserver
```

To access the MSR admin console and the APIs, you can use the `http://localhost:15555` root url, the MSR 5555 port is been remapped to 15555 in order to prevent conflicts with already existing IS / MSR running locally.  

The Hello World MSR writes into a table whose definition is located in [Messages.ddl.sql](../database/Messages.ddl.sql), use it to create the table in MySQL.  
No need to do anything regarding Universal Messaging, for the MSR is configured to dynamically create the JMS connection factory and destination.  


Once you've finished, use this command to stop the docker compose stack:
```
docker-compose down
```
In some environments, it's going to be instead:
```
docker compose down
```

##  In a local Kubernetes runtime

Needless to mention that a running (and accessible) Kubernetes cluster is required.  
I have used Minikube locally in a Macbook Silicon laptop (with a Podman driver.) So it should run smoothly on any local Kubernetes environment provided by Docker Desktop, Rancher Desktop, Orbstack, Kind or Minukube.  
To test your Kubernetes environment, run the following command:
```
kubectl get nodes
```
If it returns something like the following, then you're good to go:
```
NAME       STATUS   ROLES           AGE     VERSION
minikube   Ready    control-plane   3d18h   v1.30.0
```

Dedicated documentation will be provided for Azure AKZ, AWS EKS and GCP GKS. A few adjustments and prerequisites would have to be dealt with in these cloud environments.  

### Helm

For convenience and standardization reasons, Helm is used to install / deploy the webMethods runtimes. We use the charts provided and maintained by webMethods PS.   

Follow this webMethods Tech Community article to install Helm and the products charts: https://tech.forums.softwareag.com/t/helm-charts-deploying-webmethods-components-in-kubernetes/285781  
The Helm charts are themselves located in Github: https://github.com/SoftwareAG/webmethods-helm-charts  

Once these charts are installed, you can use the provided values.yaml file to install the products. But before that, we need to take care of a few pre-requisites.

### Pre-requisites

The following Kubernetes objects are not provided by the Helm chart:
-   product licenses config maps
-   credentials secret
-   Docker Hub and containers.webmethods.io secrets
-   persistent volume and persistent volume claim

The licenses config maps and the credentials secrets can be created using the provided [.env.example](../../kubernetes-secrets.yml.example) file. Remove the ".example" suffix and fill in the required information items in it.  
For the credentials secret, user names and passwords need to be base64 encoded. Use the following command to do so:
```
echo -n "your-secret-value" | base64
```
For the licenses config maps, just copy/paste the XML content of your webMethods licenses there. This is a YAML file, so make sure the content is correctly indented.  
Then, load these objects using this command:
```
kubectl apply -f kubernetes-secrets.yml
```

To create the Docker Hub secret, use this command:
```
kubectl create secret docker-registry dh-regcred --docker-server=docker.io --docker-username=<your-dockerhub-username> --docker-password=<your-dockerhub-token> --docker-email=<your-email>
```

To create the containers.webmethods.io secret, use this command:
```
kubectl create secret docker-registry sag-regcred --docker-server=sagcr.azurecr.io --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>
```

To create the two persistence object, you can use the provided [kubernetes-persist.yaml](../../kubernetes-persist.yaml) file. The persitent volume points to the /files folder, you can change this location to your liking. Just ensure the folder has 777 permissions to avoid access issues.  
To load these two objects, use this command:
```
kubectl apply -f kubernetes-persist.yml
```
Then, verify the persistent volume claim using this command:
```
kubectl get pvc stt-hello-world
```
It should return a status "Bound":
```
NAME              STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
stt-hello-world   Bound    pv       10Gi       RWX            manual         <unset>                 24h
```

### External dependencies

You need a MySQL service that resides outside the Kubernetes environment. Yes, you could run it inside a Kubernetes deployment, but it would not match the target architecture in which the database is provided to the CaaS "as a service".
Running a local MySQL in a laptop is fairly easy. But accessing it from a local Kubernetes environment can be a bit difficult.  
So I went for a free tiers AWS RDS MySQL instance, which is the one I am going to use at target when deploying to AWS EKS.  
Ensure network connectivity between your workstation and this database by setting the AWS security group accordingly.  

The Hello World MSR writes into a table whose definition is located in [Messages.ddl.sql](../database/Messages.ddl.sql), use it to create the table in MySQL.


TODO: API Gateway (once the microgateway is included into the setup)

### Installation of Universal Messaging

Use the provided [um-values.yaml](../deployment/um-values.yaml) to install UM with Helm.  
We use the latest vanilla 10.15 image provided in containers.webmethods.io

Use the following command to start the deployment (assuming you're in the sttHelloWorld directory):
```
helm upgrade --install umserver webmethods/universalmessaging -f ./resources/deployment/um-values.yaml
```
It should return the following:
```
Release "umserver" has been upgraded. Happy Helming!
NAME: umserver
LAST DEPLOYED: Fri Aug  9 09:49:07 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services universalmessaging)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT
```
Ignore the Notes section for the service is of type ClusterIP and is not accessible externally.  

The deployment should be completed in less than 30 seconds.  

To check the deployment:
```
kubectl get all -l app.kubernetes.io/name=universalmessaging
```
Which should return:
```
NAME                                READY   STATUS    RESTARTS      AGE
pod/umserver-universalmessaging-0   1/1     Running   0             41h

NAME                                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
service/umserver-universalmessaging-0   ClusterIP   10.105.13.40   <none>        9000/TCP,9200/TCP   41h

NAME                                           READY   AGE
statefulset.apps/umserver-universalmessaging   1/1     41h
```
Ensure pod/umserver-universalmessaging-0 is in status running.  

If you need to troubleshoot the UM deployment, here's how.  

To display the UM logs, use:
```
kubectl logs umserver-universalmessaging-0
```
To do a connectivity test, use:
```
kubectl port-forward service/umserver-universalmessaging-0 19000:9000
```
This makes the 9000 port accessible locally using nsp://localhost:19000  

To connect to the UM container, use:
```
kubectl exec -it umserver-universalmessaging-0 -- /bin/bash
```
Then you're inside the container and you can inspect its content. 

### Installation of the Hello World Microservices Runtime

Use the provided [msr-values.yaml](../deployment/msr-values.yaml) to install the MSR image with Helm.  
Here we use a custom image previously pushed to Docker Hub.  

You'll need to adjust the msr-values.yaml file:
-   In the extraConfigMaps section, you have the content of the fileAccessControl.cnf: replace the folder paths with those you want to use
-   In the microservicesruntime.propertiesFile section, you have the content of the application.properties file:
    -   place your MySQL server name in artConnection.sttHelloWorld.fr.sttlab.jdbc.jdbc_sttHelloWorld.connectionSettings.serverName
    -   place your SFTP server name in sftpserver.mft.hostName
    -   place your SFTP server port in sftpserver.mft.port
    -   place your SFTP server ssh-rsa fingerprint in sftpserver.mft.hostKey, it needs to be encoded in base64 TWICE
    -   change globalvariable.SFTP_DIRECTORY.value to a path in which you can write files in the SFTP server
    -   also change globalvariable.FILE_UPLOAD_DIRECTORY.value to match the folder path you've specified inside the fileAccessControl.cnf file

Use the following command to start the deployment (assuming you're in the sttHelloWorld directory):
```
helm upgrade --install msr-hello-world webmethods/microservicesruntime -f ./resources/deployment/msr-values.yaml
```
It should return the following:
```
Release "msr-hello-world" has been upgraded. Happy Helming!
NAME: msr-hello-world
LAST DEPLOYED: Fri Aug  9 10:46:09 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  http://msr-helloworld.local/
```

The deployment should take between 30 seconds and 2 minutes, depending on the resources available on your workstation.    

To check the deployment:
```
kubectl get all -l app.kubernetes.io/name=microservicesruntime
```
Which should return:
```
NAME                                   READY   STATUS    RESTARTS   AGE
pod/stt-hello-world-85898f58cd-ll2cc   1/1     Running   0          21h

NAME                      TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                                        AGE
service/stt-hello-world   NodePort   10.98.128.41   <none>        5555:31873/TCP,9999:31245/TCP,5543:32417/TCP   21h

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/stt-hello-world   1/1     1            1           21h

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/stt-hello-world-85898f58cd   1         1         1       21h
```
The name of the stt-hello-world pod is allocated dynamically by Kubernetes, so you're going to get a different one compared to me.  
Ensure the  stt-hello-world pod is running and ready (1/1 in column READY.)  

Then you can try accessing the MSR admin console using this URL: http://msr-helloworld.local/, but before doing so add this line to your /etc/hosts file:
```
127.0.0.1	 msr-helloworld.local
```
Make sure to use the password you've defined in the ADMIN_PASSWORD key of the msr-secrets object.  

If you can connect to the MSR admin console, then it's already a good start.  
Check the SFTP, JDBC and JMS connections, they should all be up.  

If you need to troubleshoot the MSR deployment, here's how.  

To display the MSR logs, use (replace ... with your pod name):
```
kubectl logs stt-hello-world-...
```
To connect to the UM container, use:
```
kubectl exec -it stt-hello-world-... -- /bin/bash
```
Then you're inside the container and you can inspect its content.  