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
### $FILESIZEFUNCTION
#
# command that calculates the filesize of the given file
# unknown reliability, I imagine it may cause issues on
# filesystems with compression and similar things
FILESIZEFUNCTION="stat --format='%s %n'"
### $COMMAND
#
# "prework"       or
# "postwork"            command for what part of the script to run
COMMAND=""
### $HERE
#
# /absolute/path  or
# ./relative/path or
# relative/path         top level directory for seeding files
HERE=""
### $THERE
#
# /absolute/path  or
# ./relative/path or
# relative/path         top level directory for organized files
THERE=""
### $SKIPFILESIZECHECK
#
# true or false			whether or not filesize should be checked
SKIPFILESIZECHECK=false
### $VERBOSE
#
# true or false			whether or not to diplay lots of information
VERBOSE=true

############# start of script #############

usage() {
	cat <<-endofHEREdocument
	This script will help you symbolically link files after moving/renaming 
	back into the directory you torrenting them into for continued seeding. It
	should be run before you move/rename, and then once again afterwards.

	Usage:
	$0 --prework [ -h|--here PATH ]
	$0 --postwork [ -h|--here PATH ] [ -t|--there PATH ]

	--here and --there may be specified many times

	All options:
	--help --usage ..... this text
	--prework .......... indicate prework stage
	--postwork ......... indicate postwork stage
	-h --here .......... any type of path, seeding directory
	-t --there ......... any type of path, organized directory
	--no-filesize ...... disable filesize checks in postwork
	                     may be needed for cross-filesystem work
	-v --verbose ....... output lots of words (default)
	-q --quiet   ....... supress everything but warnings
	endofHEREdocument
}

prework() {
	oldIFS="$IFS"
	IFS=":"
	read -a HERE <<< "$HERE"
	IFS="$oldIFS"

	for h in "${HERE[@]}"; do

		[[ ! -d "$h" ]] \
			&& echo "Warning: $h is not a directory. Ignoring it and moving on." \
			&& continue

		# change to the directory we are supposed to be working in
		pushd "$h" > /dev/null

		# files to hold all the sums and file sizes
		# These will always be absolute paths
		SUMSFILE="$(pwd)/mns.sums"
		FILESIZEFILE="$(pwd)/mns.sizes"
		# remove files if the exist
		[[ -f "$SUMSFILE" ]] && rm "$SUMSFILE"
		[[ -f "$FILESIZEFILE" ]] && rm "$FILESIZEFILE"

		# iterate for each file found anywhere all the way down
		find . -type f -fprint /dev/stdout \
		| while read FILE; do 

			# at this point, we are sitting in $h
			# and $FILE contains the relative path to 
			# a file somewhere deep down in $h.

			# example:
			# $h = /home/user
			# $FILE = ./Downloads/movie.mkv (which absolutely is /home/user/Downloads/movie.mkv)

			[[ $VERBOSE == true ]] && echo "finding filesize of $(basename "$FILE")"
			eval $FILESIZEFUNCTION \"$FILE\" >> "$FILESIZEFILE"

			[[ $VERBOSE == true ]] && echo -n "hashing $(basename "$FILE") ... "
			eval $HASHFUNCTION \"$FILE\" >> "$SUMSFILE"
			[[ $VERBOSE == true ]] && echo "done!"
		done

		# finally, move back to wherever we were before starting
		popd > /dev/null

	done

	
}

postwork() {

	oldIFS="$IFS"
	IFS=":"
	read -a HERE <<< "$HERE"
	read -a THERE <<< "$THERE"
	IFS="$oldIFS"

	for h in "${HERE[@]}"; do

		for t in "${THERE[@]}"; do

			# the files where sums and filesizes should be stored
			SUMSFILE="$h/mns.sums"
			FILESIZEFILE="$h/mns.sizes"
			[[ ! -f "$SUMSFILE" ]] \
				&& echo "Warning: $h/mns.sums doesn't exist, skipping directory"  \
				&& continue
			[[ $SKIPFILESIZECHECK == false ]] && [[ ! -f "$FILESIZEFILE" ]] \
				&& echo "Warning: $h/mns.sizes doesn't exist, skipping directory" \
				&& continue

			# change to directory where moved files are
			pushd "$t" > /dev/null

			find . -type f -fprint /dev/stdout \
			| while read FILE; do

				[[ $VERBOSE == true ]] && echo -n "Checking $(basename "$FILE") ... "

				# at this point, we are sitting in $t
				# and $FILE contains the relative path to 
				# a file somewhere deep down in $t.

				# contains filesize of a file in $t
				[[ $SKIPFILESIZECHECK == false ]] && FILESIZE=$( eval $FILESIZEFUNCTION \"$FILE\" | cut --delimiter=" " --fields="1" )

				# change to original location
				popd > /dev/null

				# try to find $FILE's $FILESIZE in $FILESIZEFILE
				# if it isn't found, skip hashing because $FILE
				# must not be something interesting
				# possible limitaion: fancy filesystems
				[[ $SKIPFILESIZECHECK == false ]] && MATCHES=$( grep --count $FILESIZE $FILESIZEFILE )
				
				if [[ $SKIPFILESIZECHECK == true ]] || [[ "$MATCHES" > "0" ]]; then

					pushd "$t" > /dev/null

					# contains hash of a file in $t
					HASH=$( eval $HASHFUNCTION \"$FILE\" | cut --delimiter=" " --fields="1" )

					# change to original location
					popd > /dev/null

					# try to find $FILE's $HASH in $SUMSFILE
					# and extract seeding file's name if found
					# use third field to end: second field is a second space
					# example: "8e2fd07abb4e987d1362ce880e56024d  ./ubuntu-server-disc.iso"
					SEEDFILE=$( grep "$HASH" "$SUMSFILE" | cut --delimiter=" " --fields="3-" ) 

					# if found, link the files together
					if [[ -n "$SEEDFILE" ]]; then

						[[ $VERBOSE == true ]] && echo -n "yes! "

						# calculate absolute path to $MOVEDFILE
						# if $t starts with a slash, do first thing, else do second
						[[ "$t" == /* ]] && MOVEDFILE="$t/$FILE" || MOVEDFILE="$(pwd)/$t/$FILE"

						# clean up $MOVEDFILE (probably contains /./ and // in places)
						MOVEDFILE=$(echo "$MOVEDFILE" | sed 's|/\.\?/|/|g')

						# get into $h
						pushd "$h" > /dev/null

						# make sure the directory exists for $SEEDFILE
						[[ ! -d $(dirname "$SEEDFILE") ]] && mkdir -p "$(dirname "$SEEDFILE")"

						# link to the $MOVEDFILE with $SEEDFILE
						ln -s "$MOVEDFILE" "$SEEDFILE"

						# go back to original location
						popd > /dev/null

						[[ $VERBOSE == true ]] && echo "$(basename "$SEEDFILE") now points to $(basename "$MOVEDFILE")"

					else
						[[ $VERBOSE == true ]] && echo "no (hash)"
					fi

				else
					[[ $VERBOSE == true ]] && echo "no (filesize)"
				fi

				# then go back to $t
				pushd "$t" > /dev/null

			done # while

			# finally, move back to wherever we were before starting
			popd > /dev/null

		done # for t in there

	done # for h in here


}

main() {
	# first parse the command line arguments
	# loop over all the arguments
	while [[ $# > 0 ]]; do
		ARG="$1"
		shift

		case $ARG in 
			-h|--here)
				[[ -z "$HERE" ]] && HERE="$1" || HERE="$HERE:$1"
				shift
				;;
			-t|--there)
				[[ -z "$THERE" ]] && THERE="$1" || THERE="$THERE:$1"
				shift
				;;
			--no-filesize)
				SKIPFILESIZECHECK=true
				;;
			-v|--verbose)
				VERBOSE=true
				;;
			-q|--quiet)
				VERBOSE=false
				;;
			--prework)
				COMMAND="prework"
				;;
			--postwork)
				COMMAND="postwork"
				;;
			--help|--usage)
				COMMAND="usage"
				;;
			*)
				# unknown
				;;
		esac
	done

	# do some error checking

	[[ -z "$HERE" ]] && [[ "$COMMAND" == "prework" ]] && [[ "$COMMAND" == "postwork" ]] \
		&& echo "Error: Need to specify HERE" \
		&& usage \
		&& exit 1

	[[ -z "$THERE" ]] && [[ "$COMMAND" == "postwork" ]] \
		&& echo "Error: Need to specify THERE" \
		&& usage \
		&& exit 1


	# finally move to the appropriate function


	if [[ "$COMMAND" == "prework" ]]; then
		

		prework


	elif [[ "$COMMAND" == "postwork" ]]; then
		

		postwork


	else


		usage


	fi
}


main "$@"
