# Docker Build Failed Due to Proxy Connectivity

**Date:** 2026-08-12  
**Component:** Docker / WSL2 / Windows VPN  
**Environment:** Ubuntu on WSL2  
**Severity:** Development Environment Issue  
**Status:** Resolved

---

## 1. Problem

Docker image build failed when attempting to pull the base image from Docker Hub.

Command:

```bash
docker build -t myapp:v1 .

Error:

failed to resolve reference "docker.io/library/golang:1.22-alpine":
failed to do request:
Head "https://registry-1.docker.io/v2/library/golang/manifests/1.22-alpine":
proxyconnect tcp: dial tcp 172.24.208.1:4780: i/o timeout

The Dockerfile itself was not the problem.

Docker failed before the application build started because it could not connect to Docker Hub through the configured proxy.

2. Environment

The development environment consisted of:

Windows host
WSL2
Ubuntu
Docker
Windows VPN/proxy client

The VPN proxy was listening on:

127.0.0.1:7897

Docker, however, was configured to use:

172.24.208.1:4780
3. Initial Investigation
Check Docker proxy configuration
docker info | grep -i proxy

Output:

HTTP Proxy: http://172.24.208.1:4780
HTTPS Proxy: http://172.24.208.1:4780
No Proxy: localhost,127.0.0.1

This showed that Docker was configured to use a proxy.

However, the configured port did not match the VPN proxy port.

4. Test Network Connectivity

First, test whether the proxy endpoint was reachable:

nc -vz 172.24.208.1 4780

The connection failed.

This suggested that the problem was not Docker Hub itself, but connectivity between the WSL/Docker environment and the proxy endpoint.

5. Identify the Actual VPN Proxy Port

On Windows, inspect listening ports:

netstat -ano | findstr 7897

The result showed:

TCP    127.0.0.1:7897    0.0.0.0:0    LISTENING

This confirmed that the VPN proxy was listening on:

127.0.0.1:7897

rather than:

172.24.208.1:4780
6. Verify Proxy Connectivity

Test the proxy directly from WSL:

curl -I -x http://172.24.208.1:7897 \
https://registry-1.docker.io

Successful result:

HTTP/1.1 200 Connection established
HTTP/2 404
docker-distribution-api-version: registry/2.0

The 404 response from the registry root is not the problem.

The important information is:

HTTP/1.1 200 Connection established

and:

docker-distribution-api-version: registry/2.0

This confirmed that:

WSL could reach the Windows proxy.
The proxy could establish an HTTPS connection.
Docker Registry was reachable through the proxy.
7. Root Cause

The root cause was an incorrect Docker proxy configuration.

Incorrect
http://172.24.208.1:4780
Correct
http://172.24.208.1:7897

The Windows VPN proxy was listening on port 7897, while Docker was configured to use port 4780.

Therefore:

Docker
   |
   | HTTP/HTTPS Proxy
   v
172.24.208.1:4780
   X
Connection Timeout

After correction:

Docker
   |
   | HTTP/HTTPS Proxy
   v
172.24.208.1:7897
   |
   v
Windows VPN
   |
   v
Internet
   |
   v
Docker Hub
8. Resolution

Update Docker's proxy configuration to use the correct proxy endpoint:

http://172.24.208.1:7897

After restarting/reloading Docker as required, verify:

docker info | grep -i proxy

Expected:

HTTP Proxy: http://172.24.208.1:7897
HTTPS Proxy: http://172.24.208.1:7897

Then retry:

docker build -t myapp:v1 .
9. Validation

The Docker build completed successfully.

Base image:

golang:1.22-alpine

Runtime image:

alpine:3.20

The final image was successfully created:

Successfully built e0a997cb9269
Successfully tagged myapp:v1
