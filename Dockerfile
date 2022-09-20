FROM python:3.9-alpine3.13
LABEL maintainer="jhwang90801"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# this runs a command on the alpine image that we are using when we're building our image.
# (1): creates a new virtual environment that we're going to use to store our dependencies.
# (2): want to upgrade PIP for the virtual environment that we just created.
# (3): install our requriements files.
# (4): remove the tmp directory because we don't want any extra dependencies on our image once it's being created.
#      it's best practice to keep Docker images as lightweight as possible.
# (5): it calls the ADD USER Command, whcih adds a new user insdie our image. it's best practice not to use the root user.
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \    
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# this updates the environment variable inside the image and we're updating the path environment variable.
# So the path is teh environment variable that's automatically created on Linux operating systems.
# Whenver we run any Python commands, it will run automatically from our virtual environment.
ENV PATH="/py/bin:$PATH"

USER django-user