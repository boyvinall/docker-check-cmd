This util is designed to be used with https://github.com/gliderlabs/registrator.
There's a seemingly-undocumented feature which allows you to specify consul
health checks which execute `check-cmd` on the consul host, passing in the
containerid and exposedport as arguments. This allows the service container
(e.g. redis etc) to provide the healthcheck logic, without having to copy scripts
into the consul container.

**Usage**

- Specify `SERVICE_CHECK_CMD` as an environment variable to the service
(e.g. redis/rabbit etc) container, and have this be the full path to a
script/executable.

- The script will be passed the exposedport as the only argument.
