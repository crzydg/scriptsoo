#!/bin/bash
# dig them all!
public_ns=(
    "8.8.4.4;Google"
    "8.8.8.8;Google"
    "94.140.14.14;AdGuard-CY"
    "165.87.13.129;AT&T-US"
    "1.1.1.1;Cloudflare"
    "8.26.56.26;Comodo-US"
    "168.95.1.1;HiNet-TW"
    "208.67.222.222;OpenDNS"
    "9.9.9.9;Quad9"
    "144.217.51.168;Securolytics-CA"
    "195.129.12.122;UUNET-CH"
    "192.76.144.66;UUNET-DE"
    "158.43.240.3;UUNET-UK"
    "198.6.100.25;UUNET-US"
    "64.6.64.6;Verisign-US"
    "77.88.8.8;Yandex-RU"
  )
# Default Values
record_type="A"
dig_timeout="3"
domains=()

function _usage(){
  cat <<EOF

Run DNS lookup against public NS in \$public_ns

  Usage:
        $0 --help

    -h  |  --help              Show this help
    -f  |  --file              Path to file containing domains (1 by line)
    -r  |  --record-rype       Record type [A|AAAA|CNAME|SOA|TXT|NS] (Default A)
    -d  |  --domain            Test single domain

  Nota: If both --domain and --file are specified --domain will be appended to the file list.

  Example: ./$0 --file mydomains.txt --record-type TXT

EOF
}

function _process_domain_list() {

  if [ ${file} ] && [ -f ${file} ]; then
    for dom in $(cat ${file}); do
      domains+=(${dom})
    done
  fi
  if [ ${domain} ]; then
    domains+=(${domain})
  fi

  _main
}

function _main() {
  echo "$(date)"
  echo ""

  for dom in ${domains[@]}; do
    echo -e "======================\n  $dom\n======================"
    for ns in ${public_ns[@]}; do
      nsip="$(echo ${ns} | cut -d ";" -f1)"
      nsname="$(echo ${ns} | cut -d ";" -f2)"
      echo -e "--> against ${nsip} (${nsname})"
      dig "${record_type}" @"${nsip}" +short +time="${dig_timeout}" "${dom}"
    done
  done
}


if [[ ${#} -lt 1 ]]; then
  echo "Arguments missing"
  _usage
  exit 1
fi

# Parsing positional option and arguments

while [[ ${#} -gt 0 ]]; do
  case "${1}" in
    -h | --help)
      _usage
      exit 0
      ;;
    -f | --file)
      file="${2}"
      shift 2
      ;;
    -d | --domain)
      domain="${2}"
      shift 2
      ;;
    -r | --record-type)
      record_type="${2}"
      shift 2
      ;;
      *)
      echo "${1} : Unkown option"
      _usage
      exit 1
      ;;
  esac
done

_process_domain_list

