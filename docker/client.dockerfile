# Build
FROM node:lts-alpine as builder

WORKDIR /client

# Install client dependencies
COPY client/package.json /client/package.json
COPY client/package-lock.json /client/package-lock.json
RUN npm ci

# Build client
COPY ./client/ /client/
ARG SERVER_HOST
ARG SERVER_PORT
RUN echo ${SERVER_HOST}
RUN echo ${SERVER_PORT}
RUN SERVER_HOST=${SERVER_HOST} SERVER_PORT=${SERVER_PORT} npm run build

# Host
FROM nginx:alpine

COPY --from=builder /client/build /usr/share/nginx/html
COPY client/nginx.conf /etc/nginx/default.conf
