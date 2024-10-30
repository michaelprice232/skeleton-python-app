# Use the official Python image as the base image
FROM python:3.12-alpine3.20

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

# Install Python dependencies
RUN poetry install --no-root --only main --no-interaction --no-ansi

# Copy the application files
COPY . .

# Change to non-root user
USER appuser

# Expose the port Uvicorn will run on
EXPOSE 8000

# Command to run the application
ENTRYPOINT ["uvicorn", "app.main:app"]

# Define some sane defaults which can be overridden at runtime if required
CMD ["--host", "0.0.0.0", "--port", "8000", "--workers", "2"]