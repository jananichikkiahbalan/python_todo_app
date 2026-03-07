FROM python:3.10.20-alpine3.22
COPY ./requirements.txt requirements.txt
RUN pip install -r ./requirements.txt
COPY ./app.py app.py
ENTRYPOINT [ "python" ]
CMD [ "app.py" ]
EXPOSE 5000