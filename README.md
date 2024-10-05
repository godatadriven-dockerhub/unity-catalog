## Docker Image for Unity Catalog

This Docker image runs the Unity Catalog server. latest version is 0.2.0. Both ARM64 and AMD64 are supported.


### Running the Docker Image

```bash
docker run -d -p 8080:8080 godatadriven/unity-catalog
```
This will start the Unity Catalog server and expose it on port 8080.

### Accessing the Unity Catalog
Unity catalog API is accessible at
http://localhost:8080/api/2.1/unity-catalog
For detailed API documentation, please refer to the [API documentation](https://github.com/unitycatalog/unitycatalog/tree/main/api).
).

UC CLI is at directory /app/unitycatalog/bin/uc. Working directory is set to /app/unitycatalog/

### License
This project is licensed under the Apache License 2.0 - see the [LICENSE](../../projects/unity-catalog/LICENSE) file for details.
