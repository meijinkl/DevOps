FROM python:3.11-slim-bookworm AS builder
WORKDIR /app

ENV PYTHONUSERBASE=/app/__pypackages__
COPY requirements.txt .
RUN PYTHONUSERBASE=/app/__pypackages__ pip install --user --no-cache-dir -r requirements.txt

COPY app.py .

FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/gcr.io/distroless/python3-debian12:nonroot
WORKDIR /app

COPY --from=builder --chown=nonroot:nonroot /app /app

ENV PYTHONUSERBASE=/app/__pypackages__ \
    PYTHONUNBUFFERED=1 \
    APP_VERSION=dev \
    PATH=/app/__pypackages__/bin:${PATH} \
    PYTHONPATH=/app:/app/__pypackages__/lib/python3.11/site-packages

USER nonroot:nonroot
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD ["/usr/bin/python3.11", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:5000/healthz', timeout=2)"]

CMD ["-m", "gunicorn", "-b", "0.0.0.0:5000", "-w", "2", "app:app"]