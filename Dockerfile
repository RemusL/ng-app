FROM node:19-alpine3.16 as builder

# Install Angular CLI & chrome
RUN npm install -g @angular/cli \
    && npm cache clean --force \
    && apk upgrade --no-cache --available \
    && apk add --no-cache chromium chromium-chromedriver

ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_DRIVER=/usr/bin/chromedriver

# Set working directory
WORKDIR /src

# Copy only package.json
COPY package.json .

# Install dependencies
RUN npm install

# Copy all source code
COPY . .

# Build app
RUN ng build

# Test app
LABEL layer=test
RUN ng test --no-watch --code-coverage --browsers=Chrome_without_sandox

FROM nginx:1.21-alpine

COPY nginx/default.conf /etc/nginx/conf.d/
# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*
# From 'builder' stage copy over the artifacts from dist folder to default nginx public folder
COPY --from=builder /src/dist/ng-app /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
