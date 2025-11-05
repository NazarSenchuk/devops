# syntax=docker/dockerfile:1
FROM python:3.13-slim AS build

# Copy uv binaries instead of installing via pip
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --no-dev --frozen
COPY . .

FROM python:3.13-slim AS runtime
ENV PATH="/app/.venv/bin:$PATH"
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -m -d /app -s /bin/false appuser
WORKDIR /app
COPY --from=build --chown=appuser:appgroup /app .
USER appuser
ENTRYPOINT ["python", "-m", "main"]
