## Docker Image for Unity Catalog

This Docker image is used to run the Unity Catalog server and is based on Amazon Corretto 11. 

 [Unity Catalog GitHub Repository](https://github.com/unitycatalog/unitycatalog)
### Building the Docker Image

To build the Docker image, navigate to the directory containing the Dockerfile and run the following command:

```bash
docker build -t unitycatalog .
```

### Running the Docker Image

```bash
docker run -p 8080:8080 unitycatalog
```
This will start the Unity Catalog server and expose it on port 8080.


### Dockerfile Details
The Dockerfile performs the following steps:  
1. Sets the base image to Amazon Corretto 11.
2. Sets the working directory to /app.
3. Installs git
4. Clones the Unity Catalog repository.
5. Downloads and installs sbt 1.9.8.
6. Remove git
7. Compiles Unity Catalog project 
8. Exposes port 8080. 
9. Sets the command to run the server.

### License
This project is licensed under the Apache License 2.0 - see the [LICENSE](../../projects/unity-catalog/LICENSE) file for details.