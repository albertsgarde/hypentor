FROM node:18.19-alpine3.19 AS frontend-build
WORKDIR /mattutor
COPY ./mattutor-frontend/package.json ./mattutor-frontend/package-lock.json ./
RUN npm install --frozen-lockfile

COPY ./mattutor-frontend/ .
RUN npm run build

FROM node:18.19-alpine3.19 AS frontend-prod
WORKDIR /mattutor
COPY --from=frontend-build /mattutor/ ./

ENV BACKEND_ORIGIN=http://localhost:8080

CMD PUBLIC_BACKEND_ORIGIN=${BACKEND_ORIGIN} node build
