export SCRIPTS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export MAIN_DIR="$SCRIPTS_DIR/.."

RED='\e[91m'
GREEN='\e[32m'
BLUE='\e[34m'
YELLOW='\e[33m'
CYAN='\e[36m'
GREEN_BG='\e[30;42m'

NC='\e[0m'


TEMP_DIR="$MAIN_DIR/temp"
DOWNLOAD_DIR="$MAIN_DIR/downloaded/"
VIDEOS_DIR="$DOWNLOAD_DIR/videos"

source "$SCRIPTS_DIR/subs.sh"

mkdir -p "$TEMP_DIR"
mkdir -p "$VIDEOS_DIR"


YT_DLP_ARGS='--embed-thumbnail --add-metadata --embed-metadata --embed-chapters --embed-subs --sub-langs all,-live_chat --audio-quality 0 -R infinite --retry-sleep 15 -S quality,ext:mp4,filesize --no-post-overwrites --ignore-errors --newline --no-warnings --no-playlist --convert-thumbnails png --quiet --limit-rate 2M'
# --force-keyframes-at-cuts --sponsorblock-remove all

#TITLE='%(channel)s - %(title)s.%(ext)s'
TITLE='%(title)s - %(channel)s.%(ext)s'


ANIME_DIR="$DOWNLOAD_DIR/anime"
mkdir -p "$ANIME_DIR"

# 30 GiB
FREE_SPACE=$(echo "1048576 * 30" | bc)


function _log_invidious() {
    text="${CYAN}Instance: ${YELLOW}${instance}"  
    if [ "$filename" != '' ]; then
        text="$text ${CYAN}Filename: '${BLUE}${filename}${CYAN}'"
    fi

    text="$text $1 ${NC}"
    text=$(echo "$text" | ts)
    echo -e "$text"
}


function wait_for_finish() {
    while true; do
        pgrep "yt-dlp" > /dev/null || pgrep "animdl" > /dev/null || break
        sleep 20
    done
}

function check_space() {
        # If there is less than $FREE_SPACE space left
        while [[ "$(df $VIDEOS_DIR --output=avail | tail +2)" -le "$FREE_SPACE" ]]; do
            # If no files left to delete, exit
            if [[ "$(ls $VIDEOS_DIR | wc -l)" -eq 0 ]]; then
                _log_invidious "${RED}Less than ${BLUE}$FREE_SPACE${RED} KiB on ${BLUE}$VIDEOS_DIR${RED}, exiting"
                sh "$SCRIPTS_DIR/kill.sh"
                exit 1
            fi
            # Remove the last video
            last_file="$(LC_CTYPE=C ls -t $VIDEOS_DIR | tail -1)"
            rm -f "$last_file"
        done
        pgrep "animdl" > /dev/null || animdl update > /dev/null 2>&1 &
}


function listen_rss() {
    export instance="$1"
    export feed_suffix="$2"
    export channel_id="$3"
    export rss_feed="${instance}${feed_suffix}${channel_id}"
    export index="$4"
    
    rsstail -z -l -N -n 1 -i 300 -P -u "$rss_feed" | while read url; do
        check_space

        if [[ "$url" == http* ]]; then 
            wait_for_finish

            metadata="$(yt-dlp "$url" -o "$TITLE" $YT_DLP_ARGS --print filename,upload_date)"

            export filename="$(echo "$metadata" | sed '1q;d')"

            export date="$(echo "$metadata" | sed '2q;d')"
            date_ago="$(date -d @$(echo $(date +%s) - 86400*2 | bc) -u +%Y%m%d)"

            if [ "$date" -lt "$date_ago" ]; then
                _log_invidious "${GREEN_BG}Video is too old, skipping"
            else
                _log_invidious "${CYAN}Downloading URL: ${YELLOW}${url}${CYAN}"
                yt-dlp $YT_DLP_ARGS --download-archive "$MAIN_DIR/downloaded.txt" -o "$TITLE" -P "$VIDEOS_DIR" -P "temp:$TEMP_DIR" "$url"
                
                # Change the file date to the day that the video was realeased plus the current hour, minute and second
                touch -d @"$(echo "$(date -d "$date" +%s) + $(date +%s) % 86400" | bc )" "$VIDEOS_DIR/$filename"

                
                _log_invidious "${GREEN_BG}Download done"
                check_space
            fi
        fi
    done
}

function listen_anime() {
    while true; do
        wait_for_finish
        animdl download -r 1-100 -q "best" -d "$ANIME_DIR" --index "$2" "$1"
        # 6 hours
        sleep 21600
    done
}

i=0
for feed in ${CHANNEL_FEEDS[@]}; do
    listen_rss "${INSTANCES[$i]}" "/feed/channel/" "$feed" $i &
    i=$((i+1))
    if [[ ${#INSTANCES[@]} -eq $i ]]; then
        i=0
    fi
    sleep 10
done

for feed in ${ODYSEE_FEEDS[@]}; do
    listen_rss "https://odysee.com" "/$/rss/" "$feed" $i &
    sleep 10
done

for (( i=0; i<${#ANIME[@]}; i+=2 )); do
    anime="${ANIME[i]}"
    index="${ANIME[$(expr $i + 1)]}"

    listen_anime "$anime" "$index" &
    sleep 10
done

