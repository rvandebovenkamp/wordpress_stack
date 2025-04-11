#!/bin/sh

# Try with nc (if installed)
if command -v nc >/dev/null 2>&1; then
  nc -z 127.0.0.1 3306
else
  (echo > /dev/tcp/127.0.0.1/3306) >/dev/null 2>&1
fi

