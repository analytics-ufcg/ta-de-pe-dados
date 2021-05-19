FROM python:3.6.4-alpine3.7

RUN apk --update add postgresql-client && rm -rf /var/cache/apk/*

COPY ./requirements.txt /code/scripts/requirements.txt

RUN set -ex && \
    apk update && apk add --no-cache curl tzdata libpq && \    
    apk update \
    python -m pip --no-cache install -U pip && \
    python -m pip --no-cache install -r /code/scripts/requirements.txt

CMD echo "Imagem do feed atualizada"