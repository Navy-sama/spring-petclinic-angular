ARG DOCKER_HUB="docker.io"
ARG NGINX_VERSION="1.27-alpine"
ARG NODE_VERSION="20-alpine"

FROM $DOCKER_HUB/library/node:$NODE_VERSION as build

WORKDIR /workspace

COPY package*.json ./

ARG NPM_REGISTRY="https://registry.npmjs.org"
ARG API_URL="http://backend:9966/petclinic/api/"

RUN echo "registry = \"$NPM_REGISTRY\"" > .npmrc && \
    npm ci --legacy-peer-deps

COPY . .

# Injecter l'URL du backend dans les fichiers d'environnement
RUN sed -i "s|REST_API_URL:.*|REST_API_URL: '${API_URL}'|g" src/environments/environment.prod.ts

RUN npm run build -- --base-href=/petclinic/

FROM $DOCKER_HUB/library/nginx:$NGINX_VERSION AS runtime

COPY --from=build /workspace/dist/ /usr/share/nginx/html/petclinic/
COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx && \
    sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf && \
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

EXPOSE 8080

USER nginx

HEALTHCHECK CMD ["wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080/", "||", "exit", "1"]
