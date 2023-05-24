#!/bin/sh
pkill yt-dlp
pkill rsstail
pkill ffmpeg
pkill atomicparsley
pkill animdl
/bin/ps aux | grep start_rss | grep -v grep | awk '{print $2}' | xargs kill

pkill -9 rsstail
pkill -9 yt-dlp
pkill -9 ffmpeg
pkill -9 atomicparsley
pkill -9 animdl
/bin/ps aux | grep start_rss | grep -v grep | awk '{print $2}' | xargs kill -9

