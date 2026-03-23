# ─── Build stage: install Quarto and render the site ────────────────────────
FROM debian:bookworm-slim AS builder

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gdebi-core \
    && rm -rf /var/lib/apt/lists/*

# Install Quarto CLI
ARG QUARTO_VERSION=1.8.27
RUN curl -fsSL "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
        -o /tmp/quarto.deb \
    && gdebi -n /tmp/quarto.deb \
    && rm /tmp/quarto.deb

WORKDIR /site
COPY . .

# Render the site into the docs/ output directory
RUN quarto render

# ─── Serve stage: lightweight nginx image ───────────────────────────────────
FROM nginx:alpine AS server

LABEL org.opencontainers.image.title="Alejandra Pachon – Portfolio"
LABEL org.opencontainers.image.description="Personal portfolio website for Alejandra Pachon"

# Copy the pre-built static site
COPY --from=builder /site/docs /usr/share/nginx/html

# Custom nginx config: enable gzip and proper MIME types
RUN printf 'server {\n\
    listen 80;\n\
    server_name _;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    gzip on;\n\
    gzip_types text/html text/css application/javascript application/json image/svg+xml;\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    location ~* \.(css|js|png|jpg|svg|pdf|woff|woff2)$ {\n\
        expires 1y;\n\
        add_header Cache-Control "public, immutable";\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
