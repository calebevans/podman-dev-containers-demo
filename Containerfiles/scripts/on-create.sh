#!/bin/bash

# Install required packages
if [ $SERVICE_LANG == "java" ]; then
    echo "Do any setup needed in for Java containers. Install repo dependencies, etc."
elif [ $SERVICE_LANG == "python" ]; then
    echo "Do any setup needed in for Python containers. Install repo dependencies, etc."
fi
