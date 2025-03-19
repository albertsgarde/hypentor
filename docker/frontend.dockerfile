FROM node:18.19-alpine3.19 AS frontend-build
WORKDIR /hypentor
COPY ./hypentor-frontend/package.json ./hypentor-frontend/package-lock.json ./
RUN npm install --frozen-lockfile

COPY ./hypentor-frontend/ .
RUN npm run build

FROM node:18.19-alpine3.19 AS frontend-prod
WORKDIR /hypentor
COPY --from=frontend-build /hypentor/ ./

ENV BACKEND_ORIGIN=http://localhost:8080

CMD PUBLIC_BACKEND_ORIGIN=${BACKEND_ORIGIN} node build
