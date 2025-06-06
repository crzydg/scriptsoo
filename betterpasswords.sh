#!/bin/bash

# betterpasswords.sh – secure and speakable passwords + openssl Hash
# looseley based on https://github.com/mschmitt/Dotfiles/blob/master/Scripts/bin/bestpw
# requires /usr/share/dict/words 

WORDS="/usr/share/dict/words"
CHARS=( '-' '+' '.' '*' )

# check for words
if [ ! -f "$WORDS" ]; then
  echo "❌ Wordlist '$WORDS' not found."
  echo "Install words:"
  echo "  RHEL/CentOS: sudo dnf install words"
  echo "  Debian/Ubuntu: sudo apt install wamerican"
  exit 1
fi

# read from words
readarray -t WORDS4 < <(grep -E '^[abcdefghjkmnpqrstuvwxyz]{4}$' "$WORDS" | shuf)

# generate
gen_password() {
  local word1="${WORDS4[RANDOM % ${#WORDS4[@]}]}"
  local word2="${WORDS4[RANDOM % ${#WORDS4[@]}]}"
  local num=$(printf "%03d" $((RANDOM % 1000)))
  local char="${CHARS[RANDOM % ${#CHARS[@]}]}"
  echo "${word1}${num}${char}${word2}"
}

# print
for i in {1..10}; do
  pass=$(gen_password)
  crypt=$(echo "$pass" | openssl passwd -stdin 2>/dev/null)
  md5=$(echo "$pass" | openssl passwd -1 -stdin 2>/dev/null)
  printf "%-16s %-20s %-40s\n" "$pass" "$crypt" "$md5"
done

