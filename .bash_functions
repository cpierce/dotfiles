# Easy Extraction
extract ()
  {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar fxj "$1" ;;
            *.tar.gz) tar fzx "$1" ;;
            *.bz2) bunzip "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar fxj "$1" ;;
            *.tgz) tar fzx "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file."
    fi
  }

tunnel ()
  {
    if [ ! $# -gt 2 ]; then
        echo "Usage: tunnel <tunnel-host> <tunnel-gateway> <remote-port> [local-port]"
    else
        TUNNEL_HOST="$1"
        TUNNEL_GATEWAY="$2"
        REMOTE_PORT="$3"
        if [ ! "$4" ]; then
            LOCAL_PORT="$REMOTE_PORT"
        else
            LOCAL_PORT="$4"
        fi
        echo ssh -C -N -L $LOCAL_PORT:$TUNNEL_HOST:$REMOTE_PORT $TUNNEL_GATEWAY | pbcopy
        echo 'Remote tunnel command copied to clipboard.'
    fi
  }
