# syntax=docker/dockerfile:1
ARG NODE_VERSION=22.12.0

# Stage 1 = build
FROM node:${NODE_VERSION}-alpine AS build
LABEL version=1.0
LABEL maintainer=alexander-williamson
COPY . /usr/src/app/
WORKDIR /usr/src/app
RUN npm install -g npm@latest
RUN npm install
RUN npm run build
ENTRYPOINT [ "sh" ]

# Stage 2 = server 
FROM build AS server
EXPOSE 3000
# run as non-root user
USER node
ENTRYPOINT ["npm", "run", "server"]