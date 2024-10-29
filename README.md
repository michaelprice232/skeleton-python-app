# skeleton-python-app

This project is a skeleton FastAPI application running on Uvicorn.

## Running

```shell
# Build the Docker image
make build

# Run the Docker image
make run

# Curl the default endpoint (port 8000)
make curl

# Passing custom parameters to the uvicorn entrypoint
docker run -p 9000:9000 skeleton-python-app --host "0.0.0.0" --port 9000 --workers 10
```
