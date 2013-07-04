#!/bin/bash

EXAMPLE_DIR=`dirname $0`
TOP_DIR=`dirname $0`/..

cd "$TOP_DIR"

if [ ! -f "$EXAMPLE_DIR/$1" ]; then
	node_modules/.bin/noflo "examples/$1"
else
	echo "Example $1 not found in the $EXAMPLE_DIR directory."
fi

