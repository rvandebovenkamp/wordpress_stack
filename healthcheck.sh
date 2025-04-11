#!/bin/sh
# Basic TCP port check without triggering MariaDB log warnings

nc -z 127.0.0.1 3306

