FROM node:20-alpine AS build
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install
COPY . .
RUN yarn build

FROM nginx:alpine

ARG BACKEND_HOST
ENV BACKEND_HOST=${BACKEND_HOST}

RUN apk add --no-cache gettext

COPY ./server.conf.template /etc/nginx/conf.d/default.conf.template

RUN envsubst '$$BACKEND_HOST' \
    < /etc/nginx/conf.d/default.conf.template \
    > /etc/nginx/conf.d/default.conf \
    && rm /etc/nginx/conf.d/default.conf.template

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
