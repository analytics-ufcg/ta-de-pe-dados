FROM python:3.7.12-buster

COPY ./transparencia_gov/requirements.txt /code/transparencia_gov/requirements.txt

RUN set -ex && \
    apt-get update && \
    python -m pip --no-cache install -U pip && \
    python -m pip --no-cache install -r /code/transparencia_gov/requirements.txt

WORKDIR /code
