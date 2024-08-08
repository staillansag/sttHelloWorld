# Build custom base MSR image

1.  Download the Linux installer from Empower, rename it into installer.bin and make it an executable 
2.  Set and export EMPOWER_USERNAME and EMPOWER_PASSWORD environment variables
3.  Make build.sh an executable and run it to generate a wm-msr:10.15 container image
4.  Download the MySQL JDBC driver and place it at the root of the build-base-image folder
5.  Use the Dockerfile that is at the root of the build-base-image folder to build the "final" base image and push this image to the container registry of your choice
