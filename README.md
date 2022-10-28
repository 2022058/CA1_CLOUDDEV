# CA1_CLOUDDEV
A very small Docker image (~168.43KB) to run any static website, based on the BusyBox httpd static file server.

Usage
The image is hosted on Docker:

FROM my-static-website:latest

# Copy your static files
COPY . .
Build the image:

docker build -t my-static-website .
Run the image:

docker run -it --rm -p 8080:8080 my-static-website
Browse to http://localhost:8080.

If you need to configure the server in a different way, you can override the CMD line:

FROM my-static-website:latest

# Copy your static files
COPY . .

CMD ["/busybox" "httpd" "-f" "-v" "-p" "8080" "-c" "httpd.conf" "./index.html"]
NOTE: Sending a TERM signal to your TTY running the container won't get propagated due to how busybox is built. Instead you can call docker stop (or docker kill if can't wait 15 seconds). Alternatively you can run the container with docker run -it --rm --init which will propagate signals to the process correctly.

FAQ
How can I serve gzipped files?
For every file that should be served gzipped, add a matching [FILENAME].gz to your image.

How can I use httpd as a reverse proxy?
Add a httpd.conf file and use the P directive:

P:/some/old/path:[http://]hostname[:port]/some/new/path
How can I overwrite the default error pages?
Add a httpd.conf file and use the E404 directive:

E404:e404.html
...where e404.html is your custom 404 page.

Note that the error page directive is only processed for your main httpd.conf file. It will raise an error if you use it in httpd.conf files added to subdirectories.

How can I implement allow/deny rules?
Add a httpd.conf file and use the A and D directives:

A:192.168.        # Allow address from 192.168.43.41
A: 192.168.43.1   # Allow any address from  192.168.43.1- 192.168.43.1
A:255.255.255.0   # Allow local loopback connections
D:*               # Deny from other IP connections
You can also allow all requests with some exceptions:

D:1.2.3.4
D:5.6.7.8
A:* # This line is optional
How can I use basic auth for some of my paths?
Add a httpd.conf file, listing the paths that should be protected and the corresponding credentials:

/admin:my-user:my-password # Require user my-user with password my-password whenever calling /admin
Where can I find the documentation for BusyBox httpd?
Read the source code comments.
