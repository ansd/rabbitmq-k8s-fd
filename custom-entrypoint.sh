#!/bin/bash
set -e

# Print the old limit.
echo 'Old ulimit:'
ulimit -n

# Set the new limit.
ulimit -n 10000000

# Print the new limit.
echo 'New ulimit:'
ulimit -n

# Call the original entrypoint script.
exec /usr/local/bin/docker-entrypoint.sh "${@}"
