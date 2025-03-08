# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the current directory contents (your app) into the container at /app
COPY . /app

# Install any needed dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt


# Define environment variable (optional, depends on your app)
# ENV APP_ENV=production

# Run the application when the container starts (adjust the command based on your app)
CMD ["python", "main.py"]
