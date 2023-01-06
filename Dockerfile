FROM rabbitmq:3.11.5-management

# https://github.com/kubernetes/kubernetes/issues/3595#issuecomment-288451522
COPY custom-entrypoint.sh /custom-entrypoint.sh

# https://github.com/kubernetes/kubernetes/issues/3595#issuecomment-438507708
RUN apt-get update && apt-get install -y libcap2-bin
RUN setcap cap_sys_resource=+ep /bin/bash

ENTRYPOINT ["/custom-entrypoint.sh"]
CMD ["rabbitmq-server"]
