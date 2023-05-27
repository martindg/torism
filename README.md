![OCI Image CI](https://github.com/martindg/torism/workflows/Build%20and%20Push%20Container%20Image/badge.svg)

# torism

## What is torism

**torism** is an HTTP proxy that relays traffic through the TOR network. What
is special about it is the fact that it keeps a number (specified through the
`NUM` environment variable) of TOR proxies running simultaneously. As a result,
consecutive requests will be routed randomly through different TOR proxies.

**torism** uses the following technologies:
* TOR
* ncat
* proxychains (switched to haproxy)
* haproxy

## How to use

1. Run the container
```shell
podman run --rm -it -e NUM=3 -p 9999:9999 ghcr.io/martindg/torism
```
(or if you prefer Docker)
```shell
docker run --rm -it -e NUM=3 -p 9999:9999 ghcr.io/martindg/torism
```

2. Validate the connection
```shell
curl -x socks://localhost:9000 https://check.torproject.org/api/ip
```
