FROM alpine:latest AS builder

# Install each dependency needed to build busybox
RUN apk add gcc musl-dev make perl

# Getting the busybox sources downloaded
RUN wget https://busybox.net/downloads/busybox-1.35.0.tar.bz2 \
  && tar xf busybox-1.35.0.tar.bz2 \
  && mv /busybox-1.35.0 /busybox

# Establishing a new user to protect active commands
RUN adduser -D static 

# Obtaining Web CA1's content from GitHub
RUN wget https://github.com/2022058/CA1/archive/main.tar.gz \
  && tar xf main.tar.gz \
  && rm main.tar.gz \
  && mv /CA1-main /home/static

# Changing working directory
WORKDIR /busybox

# Installing a customised BusyBox version
COPY .config .
RUN make && make install

# I'll now switch to the scratch image
FROM scratch

# Exposing container port
EXPOSE 8080

# User and customised BusyBox versions are copied to the scratch image
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /busybox/_install/bin/busybox /
# Copying Web CA1's content to the scratch image
COPY --from=builder /home/static /home/static

# The working directory of our non-root user is now selected.
USER static
## Replacing the working directory to /home/static/CA1-main
WORKDIR /home/static/CA1-main

# httpd.conf 
COPY httpd.conf .

# Launching commands after container creation
CMD ["/busybox", "httpd", "-f", "-v", "-p", "8080", "-c", "httpd.conf"]
