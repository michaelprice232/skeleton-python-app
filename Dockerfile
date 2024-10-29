# Use the official Python image as the base image
FROM python:3.13-alpine3.20

# Set environment variables for Poetry installation
ENV POETRY_VERSION=1.8.4 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_CREATE=false

# Install dependencies and create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup &&\
    apk add --no-cache  \
        curl  &&\
    curl -sSL https://install.python-poetry.org | python3 - &&\
    apk del curl &&\
    rm -rf /var/cache/apk/* &&\
    mkdir /app && chown -R appuser:appgroup /app

# Add Poetry to the PATH
ENV PATH="$POETRY_HOME/bin:$PATH"

# Set the working directory in the container
WORKDIR /app

# Copy pyproject.toml and poetry.lock to the container
COPY pyproject.toml poetry.lock ./

# Install dependencies as root
RUN poetry install --no-root --only main --no-interaction --no-ansi

# Copy the application files as the non-root user
COPY . .

# Change to non-root user
USER appuser

# Expose the port Uvicorn will run on
EXPOSE 8000

# Command to run the application
ENTRYPOINT ["uvicorn", "app.main:app"]

# Define some sane defaults which can be overridden at runtime if required
CMD ["--host", "0.0.0.0", "--port", "8000", "--workers", "2"]


# Do not put SSH keys or secrets into a Docker image. 12 factor app
# Use system group when adding group
# Use a Python alpine base image and remove python-dev package
# Pin the base image to a tag, not latest
# Use latest verison of poetry
# Version parameter not required in poetry install as we are using the POETRY_VERSION env var
# Add a WORKDIR and set the ownership to the non-root user
# Set POETRY_VIRTUALENVS_CREATE to avoid using virutal envs as installing into single image. produciton
# poetry install: --only-dev is deprecated in favour of --only main.
# Remove 'poetry run' (executes command inside virutalenv) as we have disabled virtualenvs
# Split entrypoint and cmd to enable optional config to be passed at runtime
# Add the main:app reference to CMD to reference the source app
# Remove all un-neded packages to run app. Can add more as needed. Remove curl after use and remove cache
