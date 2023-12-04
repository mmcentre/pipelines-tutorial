FROM  python:3.9.18-alpine3.18
USER root
RUN mkdir /opt/local/
COPY requirements.txt /opt/local/
RUN pip install -r  /opt/local/requirements.txt
RUN apk add gnuplot

