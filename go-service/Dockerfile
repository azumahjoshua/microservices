# Start from the official Golang image
FROM golang:1.21-alpine AS build
WORKDIR /app
COPY main.go .
RUN go build -o go-service main.go

FROM alpine:latest
WORKDIR /root/
COPY --from=build /app/go-service .
EXPOSE 8080
CMD ["./go-service"]