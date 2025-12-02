#!/bin/bash
# Analyse sshd logs: detect sessions, success, child PID, etc.

LOGFILE="$1"
[ -z "$LOGFILE" ] && { echo "Usage: $0 <logfile>"; exit 1; }

mapfile -t CONNECT_LINES < <(grep -nE "sshd\[[0-9]+\]: Connection from .+ port [0-9]+" "$LOGFILE")

for CONNECT_LINE in "${CONNECT_LINES[@]}"; do
    LINENUM=$(cut -d: -f1 <<< "$CONNECT_LINE")
    LINE=$(cut -d: -f2- <<< "$CONNECT_LINE")
    echo "$LINE"

    PARENT_PID=$(grep -oP 'sshd\[\K[0-9]+(?=\])' <<< "$LINE")
    CHILD_PID=0
    WALKED_LINES=0
    AUTH_SUCCESS=0

    # Iterate manually over following lines without a subshell
    while IFS= read -r NEXT_LINE; do
        [[ "$NEXT_LINE" =~ sshd\[([0-9]+)\]: ]] || continue
        THIS_PID="${BASH_REMATCH[1]}"

        # Stop conditions
        if [[ "$NEXT_LINE" == *"sshd[$PARENT_PID]: Connection from"* ]]; then
            echo "Stop: New connection on parent PID $PARENT_PID"
            break
        elif [[ "$NEXT_LINE" == *"sshd[$CHILD_PID]: Connection from"* && "$CHILD_PID" -ne 0 ]]; then
            echo "Stop: New connection on child PID $CHILD_PID"
            break
        elif [[ "$NEXT_LINE" == *"User child is on pid $PARENT_PID"* ]]; then
            echo "Stop: Another user child on parent PID: $PARENT_PID"
            break
        elif [[ "$NEXT_LINE" == *"User child is on pid $CHILD_PID"* && "$CHILD_PID" -ne 0 ]]; then
            echo "Stop: Another user child on child PID: $CHILD_PID"
            break
        elif [[ "$NEXT_LINE" == *"sshd[$PARENT_PID]:"* && "$NEXT_LINE" == *"session closed for user"* ]]; then
            echo "$NEXT_LINE <<< Done."
            break
        fi

        # Analyse parent PID
        if [[ "$THIS_PID" == "$PARENT_PID" ]]; then
            if [[ "$NEXT_LINE" == *"Accepted publickey"* || "$NEXT_LINE" == *"Accepted password"* ]]; then
                echo "$NEXT_LINE <<<< AUTH ACCEPTED"
            elif [[ "$NEXT_LINE" == *"session opened"* ]]; then
                echo "$NEXT_LINE <<<< SESSION OPENED"
                AUTH_SUCCESS=1
            elif [[ "$NEXT_LINE" == *"User child is on pid"* ]]; then
                CHILD_PID=$(grep -oP 'pid \K[0-9]+' <<< "$NEXT_LINE")
                echo "$NEXT_LINE <<< Got child PID: $CHILD_PID"
            elif [[ "$NEXT_LINE" != *"Deprecated pam_stack module"* ]]; then
                echo "$NEXT_LINE"
            fi
        elif [[ "$THIS_PID" == "$CHILD_PID" ]]; then
            [[ "$NEXT_LINE" != *"Deprecated pam_stack module"* ]] && echo "$NEXT_LINE"
        fi

        ((WALKED_LINES++))
        ((WALKED_LINES >= 10000)) && {
            echo "Giving up search for parent $PARENT_PID / child $CHILD_PID after $WALKED_LINES lines."
            break
        }
    done < <(tail -n +"$((LINENUM + 1))" "$LOGFILE")

    echo -n "Successful auth: "
    if ((AUTH_SUCCESS)); then
        echo "YES"
    else
        echo "NO"
    fi
    echo "---"
done

