#!/usr/bin/bash
#   Check certificates and DNS for a given domain or list of domains

###
# Default Values
default_port="443"
dependancies=("openssl" "jq" "date" "column")

function _usage(){
  cat <<EOF

Check certificates and DNS for a given domain or list of domains

  Usage:
        ${0} --help

    -h  |  --help        Show this help
    -d  |  --domain      Domain to test (can be specified multiple times)
    -d  |  --port        If needed the port can be specified (e.g example.com:8080) [default 443]
    -f  |  --file        List of domains to test against (One domain per line or domain:port if port is needed)
    -x  |  --proxy       Proxy to use. ({http,https}:// not needed)

  Examples:
    $ ${0} --domain ottobock.com --proxy http://192.168.31.134:8080
    $ ${0} --file myfile.txt --proxy http://192.168.31.134:8080
    $ ${0} -f myfile.txt -d ottobock.com -d sycor.de:8080 --proxy http://192.168.31.134:8080
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
      echo "${1}"
      ;;
  esac
}

function _check_cert_dates() {

  if [ ! -z "${proxy}"]; then
    openssl_raw_result="$(echo | openssl s_client -showcerts -connect "${1}":"${port}" -proxy "${proxy}" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null )"
  else
    openssl_raw_result="$(echo | openssl s_client -showcerts -connect "${1}":"${port}" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null )"
  fi  
  dom_not_before="$(echo "${openssl_raw_result}" | grep notBefore | sed 's/^notBefore=//;s/ GMT$//' | xargs -I{} date -d "{}" +"%a %d %b %Y %H:%M:%S")"
  dom_not_after="$(echo "${openssl_raw_result}" | grep notAfter | sed 's/^notAfter=//;s/ GMT$//' | xargs -I{} date -d "{}" +"%a %d %b %Y %H:%M:%S")"

  # Get the current date in seconds since epoch
  current_date_seconds=$(date +%s)

  # Get the "notAfter" date in seconds since epoch
  dom_not_after_sec=$(date -d "${dom_not_after}" +%s)

  # Calculate the difference in seconds and convert to days
  diff_seconds=$((dom_not_after_sec - current_date_seconds))
  diff_days=$((diff_seconds / 86400))

  # Colors the days number
  if [[ "${diff_days}" -lt 6 ]]; then
    # Red if less than 6
    diff_days="$( _msg red ${diff_days})"
  elif [[ "${diff_days}" -lt 32 ]] && [[ "${diff_days}" -gt 5 ]]; then
    # Yellow if less than 32 AND more then 5
    diff_days="$( _msg yellow ${diff_days})"
  elif [[ "${diff_days}" -gt 32 ]]; then
    # Green if more than a month
    diff_days="$( _msg green ${diff_days})"
  fi

  echo "${dom_not_before}|${dom_not_after}|${diff_days}"

}

function _check_dns() {
  # Get the IP of the given domain.
  # Use of DoH in order to bypass firewalled DNS queries
  # Request using the proxy if provided by user

  if [ -n "${proxy}" ]; then
    echo "$(curl -x ${proxy} -s -X GET "https://dns.google/resolve?name=${1}&type=A" | jq -r '.Answer[].data')"
  else
    echo "$(curl -s -X GET "https://dns.google/resolve?name=${1}&type=A" | jq -r '.Answer[].data')"
  fi
}

function _collect_results() {
  # Concatenate all results for the given domain
  # Adding new item in Array $results
  # "IP | Not Valid Before | Not Valid After | Remaining days | IP "
  results+=("${1}|${port}|$(_check_cert_dates ${1})|$(_check_dns ${1})")
}

function _print_results() {
  # Print all results from $results in a autosized table
  {
    echo -e "|----------------------------------------|------|------------------------|------------------------|------------------|---------------|"
    echo -e "|                Domain| Port |    Not Valid Before    |    Not Valid After    |  Remaining Days  |      IP |"
    echo -e "|----------------------------------------|------|------------------------|------------------------|------------------|---------------|"
    for i in $(echo ${!results[@]}); do
      echo -e "|${results[${i}]}|"
    done
  } | column -t -s $'|' -o " | "
}

function _main() {
  port="${default_port}"

  # Statements for --domain|-d switches
  if [[ -n "${domains}" ]]; then
    for domain in "${domains[@]}"; do
      if echo "${domain}" | grep -q ":"; then
        port="$(echo "${domain}" | grep -oP '(?<=:)\d+')"
        _collect_results "$( echo ${domain} | cut -d ":" -f1)"
        port="${default_port}"
      else
        _collect_results "${domain}"
      fi
    done
  fi

  # Statements for --file|-f switches
  if [[ -n "${input_file}" ]]; then
    while read line; do
      if echo "${line}" | grep -q ":"; then
        port="$(echo "${line}" | grep -oP '(?<=:)\d+')"
        _collect_results "$( echo ${line} | cut -d ":" -f1)"
        port="${default_port}"
      else
        _collect_results "${line}"
      fi
    done < "${input_file}"
  fi

  _print_results

}

# Before doing anything, make sure needed binaries are available
for dependancy in "${dependancies[@]}"; do
  if ! which "${dependancy}" > /dev/null ; then
    _msg ko "Required: ${dependancy}"
    exit 1
  fi
done

# Error and Exit if no options have been used
if [[ "${#}" -eq 0 ]]; then
  _msg ko "Oops, This script requires at least --file|-f or --domain|-d"
  _usage
  exit 1
fi

# Parsing all options/switchs
while [[ "${#}" -gt 0 ]]; do
  case "${1}" in
    -h | --help)
      _usage
      exit 0
      ;;
    -d | --domain)
      domains+=("${2}")
      shift 2
      ;;
    -p | --port)
      port="${2}"
      shift 2
      ;;
    -f | --file)
      input_file="${2}"
      shift 2
      ;;
    -x | --proxy)
      # openssl won't work with the scheme http or https. sed will remove it if provided
      proxy="$( echo ${2} | sed 's/^https\?:\/\///')"
      shift 2
      ;;
    *)
      _msg ko "${1} : Unkown option"
      _usage
      exit 1
      ;;
  esac
done

_main

