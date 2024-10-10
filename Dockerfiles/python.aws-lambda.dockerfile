# Use an official Python runtime as the base image
FROM public.ecr.aws/lambda/python:3.12

# Copy the application code and dependencies
COPY . ${LAMBDA_TASK_ROOT}

# Install any required dependencies
RUN pip3 install -r requirements.txt

# Specify the Lambda function handler
CMD ["main.lambda_handler"]
