#!/bin/bash
export DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
sh $DIR/start_rss.sh > $DIR/../log.txt 2>&1 &
