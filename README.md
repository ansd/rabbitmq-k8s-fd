## Increasing the File Descriptor Limit for RabbitMQ on K8s

This example shows how to increase the file descritpor limit (from the default limit `1048576`) when running RabbitMQ on GKE.

Not suitable for production usage.

Related issue:
https://github.com/kubernetes/kubernetes/issues/3595

Export the variables in `.envrc.template` and run `./test.sh`.

The output should print values close to 10 million:
```
File Descriptors

Total: 2, limit: 9999903
Sockets: 0, limit: 8999910
```
