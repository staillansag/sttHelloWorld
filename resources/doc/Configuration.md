#  Configuration

## Microgateway configuration

TODO

## Microservices Runtime configuration

The following objects are used to configure the MSR
-   stt-hello-world (config map) stores the application.properties file
-   msr-secrets (secret) stores credentials
-   microservicesruntime-license-key (config map) stores the MSR license

stt-hello-world is provided in the Helm values.yaml file (section microservicesruntime.propertiesFile), it contains no confidential information and can be safely placed in version control.  
The two other objects are not part of the Helm release, they are provided separately. A example yaml file is provided here: kubernetes-secrets.yml.example  

## Universal Messaging configuration

Universal Messaging only needs a universalmessaging-license-key, which is provided in the form of a config map.  
Like the MSR license, it is not part of the Helm release and needs to be provided separately. A example yaml file is provided here: kubernetes-secrets.yml.example  

Note: the JMS connection factory and destination are created dynamically by the MSR thanks to the jndi_automaticallyCreateUMAdminObjects setting defined in the application.properties file.