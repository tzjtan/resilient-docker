FROM python:3.9-slim-buster
WORKDIR /app/data

ENV FLASK_APP=app.py
ENV FLASK_RUN_PORT=5000
ENV FLASK_RUN_HOST=0.0.0.0

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

EXPOSE $FLASK_RUN_PORT
COPY . ./app/data

CMD ["flask", "run"]
