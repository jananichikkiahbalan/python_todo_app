FROM python:3.10-slim

# Install awscli and jq — needed by entrypoint.sh
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y awscli jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app/

RUN pip install -r ./requirements.txt

# Make entrypoint.sh executable inside the container
RUN chmod +x /app/entrypoint.sh

EXPOSE 5000

# entrypoint.sh runs first → fetches secrets → then starts app.py
ENTRYPOINT [ "/app/entrypoint.sh" ]