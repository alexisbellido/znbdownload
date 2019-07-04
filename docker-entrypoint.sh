#!/bin/bash
set -e

source /env/bin/activate

if [ "$1" == "production" ]; then
	# this is not being used, just here to complete the if block
	export USER=root
	export GROUP=root
else
	# this runs /bin/bash when calling docker-entrypoint.sh /bin/bash
	exec "$@"
fi