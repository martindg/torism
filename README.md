# torism

## What is torism

torism is an HTTP proxy that relays traffic through the TOR network. What is
special about it is the fact that it keeps a number (specified through the
`NUM` environment variable) of TOR proxies running simultaneously. As a result,
consecutive request will be routed through different TOR proxies.

## How to use

1. Run the container
```shell
podman run --rm -it -e NUM=3 -p 9999:9999 quay.io/martindg/torism
```
(or if you prefer Docker)
```shell
docker run --rm -it -e NUM=3 -p 9999:9999 quay.io/martindg/torism
```

2. Validate the connection
```shell
curl ipinfo.io/json -x http://localhost:9999
```
