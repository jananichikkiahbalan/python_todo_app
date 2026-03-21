FROM python:3.10-slim

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y awscli jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app/

RUN pip install -r ./requirements.txt


RUN chmod +x /app/entrypoint.sh

EXPOSE 5000


ENTRYPOINT [ "/app/entrypoint.sh" ]