FROM python:3.8-alpine as base

FROM base as builder
COPY requirements.txt /
RUN apk add gcc musl-dev python3-dev libffi-dev openssl-dev cargo
RUN pip install --prefix=/install -r requirements.txt

FROM base
COPY --from=builder /install /usr/local

COPY *.py /
ENTRYPOINT [ "python3" ]
