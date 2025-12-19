#/bin/bash
#List all redirect url for the given URL

function _usage(){
  cat <<EOF
List all redirect url for the given URL
  Usage:
        $0 --help
    -u  |  --url         URL to test
    -h  |  --help        Show this help
    -k  |  --insecure    Allow insecure server connections
    -x  |  --proxy
  Examples:
    $ ./redircheck.sh --proxy 127.0.0.1:8080 --url http://github.com
    $ ./redircheck.sh --insecure --url http://github.com
EOF
}
function _msg(){
  # Call this function to print a beautifull colored message
  # Ex: msg ko "This is an error"
  local GREEN="\\033[1;32m"
  local NORMAL="\\033[0;39m"
  local RED="\\033[1;31m"
  local PINK="\\033[1;35m"
  local BLUE="\\033[1;34m"
  local WHITE="\\033[0;02m"
  local YELLOW="\\033[1;33m"
  
  case "$1" in
    ok)
      echo -e "[$GREEN  OK  $NORMAL] $2"
      ;;
    ko)
      echo -e "[$RED FAIL $NORMAL] $2"
      ;;
    warn)
      echo -e "[$YELLOW WARN $NORMAL] $2"
      ;;
    info)
      echo -e "[$BLUE INFO $NORMAL] $2"
      ;;
    green)
      echo -e "${GREEN}${2}${NORMAL}"
      ;;
    red)
      echo -e "${RED}${2}${NORMAL}"
      ;;
    yellow)
      echo -e "${YELLOW}${2}${NORMAL}"
      ;;
    blue)
      echo -e "${BLUE}${2}${NORMAL}"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

function _main() {
  while redirect_url=$(curl $insecure $proxy --head --silent --show-error --fail --write-out "%{redirect_url}\n" --output /dev/null "${url}"); do
    echo "${url}" | grep -q "https://" && _msg green ${url} || _msg red ${url} 
    url=${redirect_url}
    [[ -z "${url}" ]] && break
  done
}

if [[ $# -eq 0 ]]; then
  _msg ko "Oops, This script requires at least --url or -u"
  _usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      _usage
      exit 0
      ;;
    -u | --url)
      url="${2}"
      shift 2
      ;;
    -x | --proxy)
      proxy="--proxy ${2}"
      shift 2
      ;;
    -k | --insecure)
      insecure="--insecure"
      shift 1
      ;;
    *)
      _msg ko "$1 : Unkown option"
      _usage
      exit 1
      ;;
  esac
done

_main

