
# Choose and name our temporary image.
FROM alpine as intermediate
# Add metadata identifying these images as our build containers (this will be useful later!)
LABEL stage=intermediate

# Take an SSH key as a build argument.
ARG SSH_PRIVATE_KEY
ARG GIT_BRANCH

# Install dependencies required to git clone.
RUN apk update && \
    apk add --update git && \
    apk add --update openssh

# 1. Create the SSH directory.
# 2. Populate the private key file.
# 3. Set the required permissions.
# 4. Add github to our list of known hosts for ssh.
RUN mkdir -p /root/.ssh/ && \
    echo "$SSH_PRIVATE_KEY"  > /root/.ssh/id_rsa && \
    chmod -R 600 /root/.ssh/ && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts


# Clone a repository (my website in this case)
RUN git clone --branch "$GIT_BRANCH" git@github.com:valinkrai/django-personal-website.git

# Pull base image
FROM python:3.7-slim

# Set environment varibles
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /code

# Install dependencies
RUN pip install pipenv
COPY Pipfile Pipfile.lock /code/
RUN pipenv install --system

# Copy project
COPY --from=intermediate /django-personal-website/ /code/
