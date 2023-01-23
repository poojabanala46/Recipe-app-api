FROM python:3.9-alpine3.13
LABEL maintainer="Pooja"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
# we are overriding this with ARG in docker compose file
RUN python -m venv /py && \
    # the above creates a virtual env for the project
    /py/bin/pip install --upgrade pip && \
    # the above shows full path to the virtual env and upgrade the pip for it
    apk add --update-- --no-cache postgresql-client && \
    # to install posgresql-client
    apk add --update --no-cache --virtual .tmp-build-deps \
    # groups the packages we installed into deps and it can be used later to delete the packages
    build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    # isntall list of requirements in docker image
    if [ $DEV="true" ]; \
    then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    # removed the tmp dir to reduce extra dependencies, so that docker image is light weight
    apk del .tmp-build-deps && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user
# adds new user inside the image. This is to avoid the root user to run the appn on the server beacuse if the appn is compromised then the attacker wld get full access to the container

ENV PATH="/py/bin:$PATH"
# it is the env variable, it defines all of the directions where the execuatbles can be run. whenevr we run any python commands it runs it from the virtual env

# everything above the user command is run by the root user. 
USER django-user

