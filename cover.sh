#!/bin/sh
# Parameters: $1: date as ##-##-## $2: venue as string $3: location as string || $1: date as ##-##-## $2: "reload" || $1: "all" $2: "reload"
bandname="grateful dead"

command -v convert >/dev/null 2>&1 || { echo >&2 "I require imagemagick but it's not installed.  Aborting."; exit 1; }

#Check for fonts...
if [ ! -f ./m6.ttf ]; then echo "Put m6.ttf in this dir... Aborting." && exit; fi
if [ -f ./m7b.ttf ]; then secfo="m7b.ttf"; else secfo="m6.ttf"; fi


function makeCover(){
	echo "$1: Making fancy cover (cover.sh)"
	# Random PAINT level
	rnd1=$((RANDOM % 13 +1))
	if [ $rnd1 -gt 10 ]; then ex1=5; else ex1=3; fi
	# Random BLUR level
	rnd2=$((RANDOM % 12 +$ex1))
	convert -size 250x250 -quality 100% xc: +noise Random   \( +clone -transpose \) \
	       	\( +clone -sparse-color voronoi '%w,0 white 0,%h black' \) \
	        -composite \
	        \( +clone -flop \) +append \
	        \( +clone -flip \) -append \
	        -virtual-pixel Tile -blur 0x$rnd2 -auto-level \
	        -separate -background white \
	        -compose ModulusAdd -paint $rnd1 -flatten -channel R -combine +channel \
	        -set colorspace HSB -colorspace RGB -fill '#030302' \
 		  	-draw "rectangle 0,340 501,501" \
		  	-fill '#fff' -draw "rectangle -1,337 501,339" \
		  	-font ./m6.ttf  -pointsize 113 -fill '#777' \
	        -draw "text  9,87 'grateful dead'" \
			-fill '#fff' -draw "text  9,85 'grateful dead'" \
			-font $secfo -pointsize 17 -fill '#777' -draw "text  20,487 '$3'" \
			-draw "text  20,469 '$2'" \
		    -pointsize 60 -draw "text  11,449 '$1'" \
		    -fill '#fff' -draw "text  12,450 '$1'"  ./output/$1/cover.jpg
}

#Parameter: $1: path to description
getDesc(){
	line=$(head -n 1 $1)
	line=$(echo $line | grep -Po "(?<=<!-- ).*?(?= -->)")
	IFS='|' read -a array <<< "$line"
	date="${array[0]}"
	venue="${array[1]}"
	location="${array[2]}"
}


### BEGIN ###
if [ "$2" == "reload" ]
then
	echo "Took Reload mode.. Reloading :DDDD"
	if [ "$1" == "all" ]
	then
		for dir in `find ./output/ -maxdepth 1 -mindepth 1 -type d`
		do
			if [ ! -f "$dir/description" ]; then
				echo "Error: File $dir/description does not exists. ignoring."
				continue
			fi
			if [ ! -f "$dir/cover.jpg" ] || [ "$3" == "force" ]
			then
				getDesc "$dir/description"
				makeCover "$date" "$venue" "$location"
			fi
		done
		exit
	else
		if [ ! -d "./output/$1" ]; then
			echo "Error: Directory ./output/$1. Generating half-empty cover instead :P."
			date=$1
			venue=""
			location=""
		else
			getDesc "./output/$1/description"
		fi
	fi
else
	date=$1
	venue=$2
	location=$3
fi
if [ ! -d "./output/$1" ]; then mkdir "./output/$1"; fi
makeCover "$date" "$venue" "$location"
