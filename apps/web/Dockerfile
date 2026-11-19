FROM docker.io/debian:13-slim

COPY --from=ghcr.io/jdx/mise:2026.10.13 /usr/local/bin/mise /usr/local/bin/mise

RUN apt-get update \
    && apt-get -y --no-install-recommends install ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV PATH="/mise/shims:$PATH"

WORKDIR /app
COPY mise.toml ./
RUN mise trust && mise install

COPY pyproject.toml ./
RUN mise exec -- uv sync

COPY . .
RUN mise exec -- uv run python manage.py tailwind build
RUN mise exec -- uv run python manage.py collectstatic --no-input

CMD ["mise", "exec", "--", "python", "launcher.py"]
