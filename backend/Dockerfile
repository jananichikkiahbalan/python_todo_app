FROM python:3.10.20-alpine3.22
RUN apk update && apk upgrade
RUN pip install --upgrade pip wheel
COPY ./requirements.txt requirements.txt
RUN pip install -r ./requirements.txt
COPY ./app.py app.py
ENTRYPOINT [ "python" ]
CMD [ "app.py" ]
EXPOSE 5000
