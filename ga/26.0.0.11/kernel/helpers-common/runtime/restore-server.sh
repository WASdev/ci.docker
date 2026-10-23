#!/bin/bash

# For restore use a copy of criu that does not have sys_ptrace
export CRIU_RESTORE_PATH=/opt/criu/criu
exec "$@"

