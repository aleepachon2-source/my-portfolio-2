# Serve the pre-built static site (docs/) with nginx
FROM nginx:alpine

LABEL org.opencontainers.image.title="Alejandra Pachon – Portfolio"
LABEL org.opencontainers.image.description="Personal portfolio website for Alejandra Pachon"

# Copy the pre-rendered Quarto output into nginx's web root
COPY docs /usr/share/nginx/html

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
    location ~* \\.(css|js|png|jpg|svg|pdf|woff|woff2)$ {\n\
        expires 1y;\n\
        add_header Cache-Control "public, immutable";\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
