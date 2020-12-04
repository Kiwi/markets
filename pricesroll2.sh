#!/bin/zsh

xterm -geometry 8x1 -e "$HOME/bin/markets/binance.sh -aw2 btcusdt" &|

xterm -geometry 8x1 -e "$HOME/bin/markets/foxbit.sh -p" &|

xterm -geometry 8x1 -e 'while true ;do bash "$HOME/bin/markets/novad.sh" -2 | xargs -n1 printf "\n%.2f" ;sleep 5 ;done' &|

