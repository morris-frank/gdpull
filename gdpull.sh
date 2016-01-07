#!/bin/sh

function GDPull(){
	#Date
	date=$(grep -Eo '([0-9]{2}-){2}[0-9]{2}' <<< "$1" | \head -1)

	echo "$date: Downloading website content"
	trap "rm -f ./$date.site.html" 1 2 15
	wget -q "$1" -O "$date.site.html"

	#Link
	dlink="http://archive.org"$(awk -F\" '/m3u/ {for (i=2; i<=NF; i++) {if ($i ~/m3u/) {print $i; exit} } }' "$date.site.html")
	#VENUE
	venue=$(awk -F'[<>]' '/Venue/ {for (i=1; i<=NF; i++) {if ($i ~/Venue/) print $(i+6)} }' "$date.site.html")
	#Location
	location=$(awk -F'[<>]' '/Location/ {for (i=1; i<=NF; i++) {if ($i ~/Location/) print $(i+6)} }' "$date.site.html")

	rm -f "$date.site.html" && trap 1 2 15

	mkdir -p "./output/$date"

	echo "<!-- $date|$venue|$location -->" > "./output/$date/description"

	#Cover Generation
	echo "$date: Making cover"
	timeout 20 ./cover.sh "$date" "$venue" "$location"

	echo "$date: DL Stream List"
	wget -q "$dlink" -O "./output/$date/$date.m3u"
	echo "$date: DL Streams"
	wget -nv -i "./output/$date/$date.m3u" -P "./output/$date"
}


for var in "$@"; do
	echo "$var" | egrep -q '(https?:\/\/)?archive\.org\/details\/.?'
	if [[ $? -eq 0 ]]; then
		GDPull "$var" &
	fi
done
wait

