#!/bin/sh

echo "[Compile]"
OUT=$(dub build 2>&1)
bin/rcd 1>/dev/null 2>&1 &
PID=$!
echo "    [Ready]"

inotifywait -m ./rcd -r 2>/dev/null | while read -r dir event name; do
    if [ "$event" == "MODIFY" -o "$event" == "MOVED_TO" ]; then
        echo $name | grep -P "\.dt?$" > /dev/null
        if [ $? -eq 0 ]; then
            echo "[Compile]"
            OUT=$(dub build 2>&1)
            if [ $? -eq 0 ]; then
                echo "    [Reload]"
                kill $PID
                if [ $? -ne 0 ]; then
                    echo "[Hard Kill]"
                    kill -9 $PID
                fi
                sleep 1s

                bin/rcd 1>/dev/null &
                PID=$!

                echo "    [Ready]"
            else
                echo "    [Build Failed]"
                echo $OUT
                echo ""
            fi
        fi
    fi
done