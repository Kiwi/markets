#!/bin/bash
# Bitstamp.sh  -- Websocket access to Bitstamp.com
# v0.3.7  ago/2020  by mountainner_br

#defaults
#market
MKTDEF=btcusd

#do not change the following
export LC_NUMERIC=C
COLOROPT="cat"
DECIMAL=2

HELP="SYNOPSIS
	bitstamp.sh [-c] [-fNUM] [-is] [MARKET]
	bitstamp.sh [-hlv]


DESCRIPTION
	This script accesses the Bitstamp Exchange public API and fetches
	market data. Currently, only the live trade stream is implemented.

	If no market is given, sets $MKTDEF by defaults. If no option is
	set, sets option -s by defaults.

	Options -s and -i shows the same data as in:
	<https://www.bitstamp.net/s/webapp/examples/live_trades_v2.html>

	For very small rates, set decimal plates with option -NUM, in
	which NUM is an integer.


WARRANTY
	Licensed under the GNU Public License v3 or better and is
	distributed without support or bug corrections.

	This programme requires latest version of Bash, JQ, Websocat
	and Lolcat.

	If you found this script useful, consider giving me a nickle!
		=)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


OPTIONS
	-f [NUM] 	Set number of decimal plates; defaults=2 .
	-i [MARKET] 	Live trade stream with more info.
	-h 	 	Show this help.
	-l 	 	List available markets.
	-s [MARKET] 	Live trade stream (default opt).
	-c		Coloured prices; only for use with option -s .
	-v 		Show this programme version."
# From: https://www.bitstamp.net/websocket/v2/

#markets
CPAIRS=(bchbtc bcheur bchusd btceur btcusd ethbtc etheur ethusd eurusd ltcbtc ltceur ltcusd xrpbtc xrpeur xrpusd)


## Trade stream - Bitstamp Websocket for Price Rolling
streamf() {
	while true
	do
		echo "{ \"event\": \"bts:subscribe\",\"data\": { \"channel\": \"live_trades_${1,,}\" } }" |
			websocat -nt --ping-interval 20 "wss://ws.bitstamp.net" |
			jq --unbuffered -r '.data.price // empty' |
			while read
			do
				printf "\n%.${DECIMAL}f" "$REPLY"
			done |
			${COLOROPT}

		((N++))
		printf "\nPress Ctrl+C twice to exit.\n"
		printf "Recconection #${N}\n"
		sleep 4
	done
	exit
}

# Trade stream more info
istreamf() {
	while true
	do
		echo "{ \"event\": \"bts:subscribe\",\"data\": { \"channel\": \"live_trades_${1,,}\" } }" |
			websocat -nt --ping-interval 20 "wss://ws.bitstamp.net" |
			jq --unbuffered -r '.data|"P: \(.price // empty) \tQ: \(.amount // empty) \tPQ: \((if .price == null then 1 else .price end)*(if .amount == null then 1 else .amount end)|round)    \t\(.timestamp // empty|tonumber|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))"' |
			${COLOROPT}
		
		((N++))
		printf "\nPress Ctrl+C twice to exit.\n"
		printf "Recconection #${N}\n"
		sleep 4
	done
	exit
}


# Parse options
while getopts :cf:lhsiv opt
do
  case ${opt} in
  	l ) # List Currency pairs
		printf "Markets:\n"
		printf "%s\n" "${CPAIRS[*]^^}"
		printf "Also check <https://www.bitstamp.net/websocket/v2/>.\n"
		exit
		;;
	f ) # Decimal plates
		DECIMAL="${OPTARG}"
		;;
	h ) # Show Help
		printf "%s\n" "${HELP}"
		exit 0
		;;
	i ) # Price stream with more info
		ISTREAMOPT=1
		;;
	s ) # B&W price stream
		STREAMOPT=1
		;;
	c ) # Coloured price stream
		COLOROPT="lolcat -p 2000 -F 5"
		;;
	v ) # Version of Script
		head "${0}" | grep -e '# v'
		exit
		;;
	\? )
		echo "Invalid Option: -$OPTARG" 1>&2
		exit 1
		;;
  esac
done
shift $((OPTIND -1))


## Check if there is any argument
## And set defaults
if ! [[ "${1}" =~ [a-zA-Z]+ ]]
then
	set -- "$MKTDEF"
fi
#all to lower case
set -- "${@,,}"
#try to form a market pair
set -- "$1$2"

## Check for valid market pair
if [[ \ "${CPAIRS[*]}"\  != *\ "${1,,}"\ * ]]
then
	printf "Usupported market/currency pair.\n" 1>&2
	printf "Run with -l to list available markets.\n" 1>&2
	exit 1
fi

# Run Functions

# Trade price stream
[[ -n "$STREAMOPT" ]] && streamf "${@}"
# Trade price stream with additional information
[[ -n "$ISTREAMOPT" ]] && istreamf "${@}"
#default opt
streamf "${@}"

