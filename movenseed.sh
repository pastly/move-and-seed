#!/bin/bash

###############################################################################
# Author: Matt Traudt
# Originally created: 2014-06-11
# Maintained at: https://bitbucket.org/pointychimp/move-and-seed
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################

### $HASHFUNCTION
#
# command that will be used to hash every file
# sha1sum would be another good option, but performed
# slower for me in my cursory tests
HASHFUNCTION="md5sum" 
### $COMMAND
#
# "prework"       or
# "postwork"            command for what part of the script to run
COMMAND="$1"
### $HERE
#
# /absolute/path  or
# ./relative/path or
# relative/path         top level directory for seeding files
#                       used for both commands
HERE="$2"
### $THERE
#
# /absolute/path  or
# ./relative/path or
# relative/path         top level directory for organized files
#                       only used for postwork command
THERE="$3"

############# start of script #############

usage() {
	echo "
This script will help you symbolically link files after moving/renaming
back into the directory you torrenting them into for continued seeding.
It should be run before you move/rename, and then once again afterwards.

The inspiration for this script came from torrenting lots of Linux ISOs
and wanting to continue seeding and supporting them while also 
reorganizing them elsewhere on the computer.

The commands are as follows.

$(basename "$0") example
             Prints out a full example of how this script
             can be used. It pipes the text through \"less\"
             as there is a lot.

$(basename "$0") prework <dir>
			 This should be run before moving.

			 Recursively hashes all the files in <dir>.
			 A file in <dir> will be created containing
			 all the hashes. This will take a long time
			 for large directories!

$(basename "$0") postwork <dir1> <dir2>
			 This should be run after moving and can be run
			 multiple times for multiple <dir2>'s.

			 Here, <dir1> should be the same as <dir> from 
			 prework. <dir2> should be where things were   
			 moved. <dir1> can still contain anything you  
			 didn't want to move and must contain that hash 
			 file generated in the prework.
"
}

example() {
	echo "
Your torrented a discography for an artist that released all their work for
free. You want to continuing supporting the artist by seeding for a long time,
but don't like the way they organized the files or included a bunch of annoying 
text files. You also want to save space, so having two copies of the music--one
for listening, one for seeding--is not ideal. 

================================= PREPARATION =================================

The download has finished and you have the following directory structure.

/downloads/free-artist-discography
├── album1
│   ├── cover.jpg
│   ├── song1.mp3
│   ├── song2.mp3
│   ├── song3.mp3
│   └── track-list.txt
├── album2
│   ├── cover.jpg
│   ├── song1.mp3
│   ├── song2.mp3
│   ├── song3.mp3
│   └── track-list.txt
├── album3
│   ├── cd1
│   │   ├── song1.mp3
│   │   ├── song2.mp3
│   │   └── song3.mp3
│   ├── cd2
│   │   ├── song1.mp3
│   │   ├── song2.mp3
│   │   └── song3.mp3
│   ├── cover.jpg
│   └── track-list.txt
├── another-txt-file.txt
├── readme.txt
└── see-us-at-venue.txt

From inside /downloads/free-artist-discography, you will run
	$(basename "$0") prework ./
Or from anywhere you will run
	$(basename "$0") prework /downloads/free-artist-discography

Once finished (this could take a long time if the albums are very large), a new
file will be in /downloads/free-artist-discography containing a list of all the
files and their hashes. You are now free to move any of the files and folders 
to whever you want on the filesystem. 

Let's say you personally like album1 and album2, so you put it in a directory
to be later synced with your mp3 player. Album3 isn't so good, but your
brother has bad taste in music so he likes it. You put it in a public folder so
he can access it.

================================== POST WORK ==================================

You've finished moving things and relevant directories look like this now.

/downloads/free-artist-discography
├── album1
│   ├── cover.jpg
│   └── track-list.txt
├── album2
│   ├── cover.jpg
│   └── track-list.txt
├── album3
│   ├── cover.jpg
│   └── track-list.txt
├── another-txt-file.txt
├── mns.sums
├── readme.txt
└── see-us-at-venue.txt

/my-music
└── free-artist
    ├── album1 [year]
    │   ├── artist-album-song1.mp3
    │   ├── artist-album-song2.mp3
    │   └── artist-album-song3.mp3
    └── album2 [year]
        ├── artist-album-song1.mp3
        ├── artist-album-song2.mp3
        └── artist-album-song3.mp3

/public/free-artist
├── album3 disc1
│   ├── song1.mp3
│   ├── song2.mp3
│   └── song3.mp3
└── album3 disc2
    ├── song1.mp3
    ├── song2.mp3
    └── song3.mp3

You should now this script twice, once for each of the directories you moved
files to. 

From /downloading/free-artist-discography you run
	$(basename "$0") postwork ./ /my-music/free-artist
	$(basename "$0") postwork ./ /public/free-artist
Or from anywhere you run
	$(basename "$0") postwork /downloading/free-artist-discography /my-music/free-artist
	$(basename "$0") postwork /downloading/free-artist-discography /public/free-artist

Inside /downloading/free-artist-discography you should now have symbolic links
pointing towards all those .mp3 files, even though you changed the directory
structure and even renamed some of them.

/downloads/free-artist-discography
├── album1
│   ├── cover.jpg
│   ├── song1.mp3 -> /my-music/free-artist/album1 [year]/artist-album-song1.mp3
│   ├── song2.mp3 -> /my-music/free-artist/album1 [year]/artist-album-song2.mp3
│   ├── song3.mp3 -> /my-music/free-artist/album1 [year]/artist-album-song3.mp3
│   └── track-list.txt
├── album2
│   ├── cover.jpg
│   ├── song1.mp3 -> /my-music/free-artist/album2 [year]/artist-album-song1.mp3
│   ├── song2.mp3 -> /my-music/free-artist/album2 [year]/artist-album-song2.mp3
│   ├── song3.mp3 -> /my-music/free-artist/album2 [year]/artist-album-song3.mp3
│   └── track-list.txt
├── album3
│   ├── cd1
│   │   ├── song1.mp3 -> /public/free-artist/album3 disc1/song1.mp3
│   │   ├── song2.mp3 -> /public/free-artist/album3 disc1/song2.mp3
│   │   └── song3.mp3 -> /public/free-artist/album3 disc1/song3.mp3
│   ├── cd2
│   │   ├── song1.mp3 -> /public/free-artist/album3 disc2/song1.mp3
│   │   ├── song2.mp3 -> /public/free-artist/album3 disc2/song2.mp3
│   │   └── song3.mp3 -> /public/free-artist/album3 disc2/song3.mp3
│   ├── cover.jpg
│   └── track-list.txt
├── another-txt-file.txt
├── mns.sums
├── readme.txt
└── see-us-at-venue.txt

=============================== WORD OF WARNING ===============================

This script works by matching hashes; therefore, you need to be careful about
which directories you choose for the post work. You want to get as close to the
files as possible to avoid having to digest files that aren't related to the
torrent. Using the above example, if you have lots of other artists in the
/my-music directory, you would not want to use
	
	$(basename "$0") /downloading/free-artist-discography /my-music

as it would digest ever single file in /my-music and potentially take forever.
Similarly, if you put the torrented music files in the same directory as
unrelated files, you will end up digesting the unrelated files. There's nothing
wrong with this, other than you will have an unavoidable waste of time if there
is lots of large unrelated files. 
"
}

prework() {
	# change to the directory we are supposed to be working in
	pushd "$HERE" > /dev/null

	# file to hold all the sums
	# This will always be an absolute path
	SUMSFILE="$(pwd)/mns.sums"
	# remove $SUMEFILE if it exists
	[[ -f "$SUMSFILE" ]] && rm "$SUMSFILE"

	# iterate for each file found anywhere all the way down
	find . -type f -fprint /dev/stdout \
	| while read FILE; do 

		# at this point, we are sitting in $HERE
		# and $FILE contains the relative path to 
		# a file somewhere deep down in $HERE.

		# example:
		# $HERE = /home/user
		# $FILE = ./Downloads/movie.mkv (which absolutely is /home/user/Downloads/movie.mkv)

		echo -n "hashing $(basename "$FILE") ... "
		$HASHFUNCTION "$FILE" >> "$SUMSFILE"
		echo "done!"
	done

	echo "
Everything in $HERE is now digested and stored in $HERE/mns.sums

You can now move whatever files you want out of here to wherever you want.
Any files you do not want to keep should stay in this directory.

When you are done, come back to this directory and
run the following command once for each <dir2> needed until
all the files are symbolically linked.

	$(basename "$0") postwork $HERE <dir2>
"

	# finally, move back to wherever we were before starting
	popd > /dev/null
}

postwork() {
	# the file where sums should be stored
	SUMSFILE="$HERE/mns.sums"
	[[ ! -f "$SUMSFILE" ]] && echo "Error: $HERE/mns.sums doesn't exist" && exit 1

	# change to directory where moved files are
	pushd "$THERE" > /dev/null

	find . -type f -fprint /dev/stdout \
	| while read FILE; do

		echo -n "Checking $(basename "$FILE") ... "

		# at this point, we are sitting in $THERE
		# and $FILE contains the relative path to 
		# a file somewhere deep down in $THERE.

		# contains hash of a file in $THERE
		HASH=$( $HASHFUNCTION "$FILE" | cut --delimiter=" " --fields="1" )

		# change to original location
		popd > /dev/null

		# try to find $FILE's $HASH in $SUMSFILE
		# and extract seeding file's name if found
		# use third field to end: second field is a second space
		# example: "8e2fd07abb4e987d1362ce880e56024d  ./ubuntu-server-disc.iso"
		SEEDFILE=$( grep "$HASH" "$SUMSFILE" | cut --delimiter=" " --fields="3-" ) 
		
		# if found, link the files together
		if [[ -n "$SEEDFILE" ]]; then

			echo -n "yes! "

			# calculate absolute path to $MOVEDFILE
			# if $THERE starts with a slash, do first thing, else do second
			[[ "$THERE" == /* ]] && MOVEDFILE="$THERE/$FILE" || MOVEDFILE="$(pwd)/$THERE/$FILE"
			
			# clean up $MOVEDFILE (probably contains /./ and // in places)
			MOVEDFILE=$(echo "$MOVEDFILE" | sed 's|/\.\?/|/|g')
			
			# get into $HERE
			pushd "$HERE" > /dev/null

			# make sure the directory exists for $SEEDFILE
			[[ ! -d $(dirname "$SEEDFILE") ]] && mkdir -p "$(dirname "$SEEDFILE")"
			
			# link to the $MOVEDFILE with $SEEDFILE
			ln -s "$MOVEDFILE" "$SEEDFILE"
			
			# go back to original location
			popd > /dev/null

			echo "$(basename "$SEEDFILE") now points to $(basename "$MOVEDFILE")"

		else
			echo "no"
		fi
		
		# then go back to $THERE
		pushd "$THERE" > /dev/null


	done


	# finally, move back to wherever we were before starting
	popd > /dev/null
}

main() {
	## do some error checking first

	[[ "$COMMAND" != "prework" ]] && [[ "$COMMAND" != "postwork" ]] && [[ "$COMMAND" != "example" ]] \
	&& echo "Error: Not a valid command" && usage && exit 1

	[[ "$COMMAND" != "example" ]] && [[ ! -d "$HERE" ]] \
	&& echo "Error: Directory $HERE does not exist" && usage && exit 1

	[[ "$COMMAND" == "postwork" ]] && [[ ! -d "$THERE" ]] \
	&& echo "Error: Directory $THERE does not exist" && usage && exit 1

	## end of error checking

	if [[ "$COMMAND" == "prework" ]]; then
		

		prework


	elif [[ "$COMMAND" == "postwork" ]]; then
		

		postwork


	elif [[ "$COMMAND" == "example" ]]; then
		

		example | less


	fi
}


main
