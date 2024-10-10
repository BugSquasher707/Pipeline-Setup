# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install -r app/requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Set environment variables
ENV DJANGO_SETTINGS_MODULE='config.settings.development'

# Set the working directory in the container
WORKDIR /app/app

# Run the application
CMD [ "python3", "manage.py", "runserver" ]