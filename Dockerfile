# Use a base image with Python 3.9 installed (multi-platform)
FROM --platform=${BUILDPLATFORM} python:3.9-slim-buster

# Set working directory
WORKDIR /app

# Set environment variable for Git Python
ENV GIT_PYTHON_REFRESH=quiet

# Install system dependencies and clean up apt cache
RUN apt-get update && apt-get install -y \
    git \
    tree && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user with a specific UID and GID (i.e. 1000 in this case)
RUN groupadd -r tempuser -g 1000 && \
    useradd -r -u 1000 -g tempuser tempuser && \
    mkdir -p /home/tempuser && \
    chown -R tempuser:tempuser /home/tempuser

# Set permissions for the working directory to the new user
RUN chown tempuser:tempuser /app

# Switch to the new user
USER tempuser

# Add the directory where pip installs user scripts to the PATH
ENV PATH=/home/tempuser/.local/bin:$PATH

# Install the readmeai package from PyPI with a pinned version
RUN pip install readmeai --upgrade

COPY . .

# Expose port 8501 for Streamlit
EXPOSE 8501

# Set the command to run the Streamlit server
CMD ["streamlit", "run", "src/streamlit_app.py"]
