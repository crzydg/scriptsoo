#!/bin/bash
# function to use betterpasswords.sh – secure and speakable passwords + openssl Hash
# looseley based on https://github.com/mschmitt/Dotfiles/blob/master/Scripts/bin/bestpw
# requires /usr/share/dict/words #
WORDS="/usr/share/dict/words"
CHARS=( '-' '+' '.' '*' )
function gen_password() {
  readarray -t WORDS4 < <(grep -E '^[abcdefghjkmnpqrstuvwxyz]{4}$' "$WORDS" | shuf)
  local word1="${WORDS4[RANDOM % ${#WORDS4[@]}]}"
  local word2="${WORDS4[RANDOM % ${#WORDS4[@]}]}"
  local num=$(printf "%03d" $((RANDOM % 1000)))
  local char="${CHARS[RANDOM % ${#CHARS[@]}]}"
  echo "${word1}${num}${char}${word2}"
}
gen_password
