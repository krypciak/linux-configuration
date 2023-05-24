if [ "$(whoami)" != "root" ]; then
    echo "This script requires root privilages"
    exit 1
fi

if [ "$SAMBA_USER" == "" ]; then
    echo "Set \$SAMBA_USER to a valid samba user."
    exit 2
fi


SCRIPTS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MAIN_DIR="$SCRIPTS_DIR/.."

source "$SCRIPTS_DIR/dirs.sh"

for ((i = 0; i < ${#DIRS[@]}; i++)); do
    dir="$MAIN_DIR/downloaded/${DIRS[$i]}"
    mkdir -p -v "$dir"
    chown $SAMBA_USER:$SAMBA_USER -v "$dir"
    chmod 770 -v "$dir"
done

