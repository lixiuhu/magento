#!/usr/bin/env bash
chown -R nginx:nginx /var/www
exec "$@"
