FROM python:3.10-slim
RUN apt-get update && apt-get upgrade -y && apt-get dist-clean
WORKDIR /app
COPY . /app/
RUN pip install -r ./requirements.txt
CMD [ "python", "app.py" ]
EXPOSE 5000