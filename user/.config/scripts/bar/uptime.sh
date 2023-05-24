#!/bin/sh
uptime --pretty | tail -c +4 | sed -E -e 's/ (minutes|minute)/m/g' -e 's/ (hours|hour)/h/g' -e 's/ (day|days)/d/g'
