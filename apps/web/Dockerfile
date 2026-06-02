FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
ARG PUBLIC_API_URL=http://localhost:8080/api
ENV PUBLIC_API_URL=${PUBLIC_API_URL}
RUN npm run build

FROM caddy:2-alpine
COPY --from=builder /app/dist /srv/www
COPY Caddyfile.docker /etc/caddy/Caddyfile
EXPOSE 80
