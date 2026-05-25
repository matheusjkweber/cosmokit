FROM golang:1.26-bookworm AS build
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -mod=vendor -trimpath -ldflags="-s -w" -o /out/app ./cmd/cosmokit-api

FROM gcr.io/distroless/base-debian12
COPY --from=build /out/app /app
EXPOSE 8091
ENV PORT=8091
USER nonroot:nonroot
ENTRYPOINT ["/app"]
