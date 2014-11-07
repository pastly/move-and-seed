# INTRO

This is a handy little bash script that allows you to move torrented files around without disrupting your ability to seed them.

Please report bugs at the [issue tracker](https://bitbucket.org/pointychimp/move-and-seed/issues).

If you like this and find it useful, consider sending a few bitcents my way: [17wNska6TeMDYeDGzzv26sExXP8FAKHGQ7](bitcoin:17wNska6TeMDYeDGzzv26sExXP8FAKHGQ7).

# USAGE

	This script will help you symbolically link files after moving/renaming 
	back into the directory you torrenting them into for continued seeding. It
	should be run before you move/rename, and then once again afterwards.

	Usage:
	movenseed.sh --prework [ -h|--here PATH ]
	movenseed.sh --postwork [ -h|--here PATH ] [ -t|--there PATH ]

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

# WORD OF WARNING

This script uses file sizes as a quick check to see if files are potentially
the same before moving on to hashing to find out for sure. If you use advanced
filesystems like zfs or even two different filesystems for `--here` and `--there`,
you may need to specify `--no-filesize` for postwork.

# EXAMPLE

Your torrented a discography for an artist that released all their work for
free. You want to continuing supporting the artist by seeding for a long time,
but don't like the way they organized the files or included a bunch of annoying 
text files. You also want to save space, so having two copies of the music--one
for listening, one for seeding--is not ideal. 

### PREPARATION

The download has finished and you have the following directory structure.

	/downloads/free-artist-discography
	├── album1
	│   ├── cover.jpg
	│   ├── song1.mp3
	│   ├── song2.mp3
	│   ├── song3.mp3
	│   └── track-list.txt
	├── album2
	│   ├── cover.jpg
	│   ├── song1.mp3
	│   ├── song2.mp3
	│   ├── song3.mp3
	│   └── track-list.txt
	├── album3
	│   ├── cd1
	│   │   ├── song1.mp3
	│   │   ├── song2.mp3
	│   │   └── song3.mp3
	│   ├── cd2
	│   │   ├── song1.mp3
	│   │   ├── song2.mp3
	│   │   └── song3.mp3
	│   ├── cover.jpg
	│   └── track-list.txt
	├── another-txt-file.txt
	├── readme.txt
	└── see-us-at-venue.txt

You may copy the script to wherever you will be using it. From inside
`/downloads/free-artist-discography`, you will run
	
	./movenseed.sh --prework --here ./

Or from anywhere you will run
	
	./movenseed.sh --prework --here /downloads/free-artist-discography

Once finished (this could take a long time if the albums are very large), new
files will be in `/downloads/free-artist-discography` containing a list of all
the files and their hashes and sizes. You are now free to move any of the files
and folders to whever you want. 

Let's say you personally like album1 and album2, so you put it in a directory
to be later synced with your mp3 player. Album3 isn't so good, but your
brother has bad taste in music so he likes it. You put it in a public folder so
he can access it.

### POST WORK 

You've finished moving things and relevant directories look like this now.

	/downloads/free-artist-discography
	├── album1
	│   ├── cover.jpg
	│   └── track-list.txt
	├── album2
	│   ├── cover.jpg
	│   └── track-list.txt
	├── album3
	│   ├── cover.jpg
	│   └── track-list.txt
	├── another-txt-file.txt
	├── mns.sizes
	├── mns.sums
	├── readme.txt
	└── see-us-at-venue.txt

	/my-music
	└── free-artist
	    ├── album1 [year]
	    │   ├── artist-album-song1.mp3
	    │   ├── artist-album-song2.mp3
	    │   └── artist-album-song3.mp3
	    └── album2 [year]
	        ├── artist-album-song1.mp3
	        ├── artist-album-song2.mp3
	        └── artist-album-song3.mp3

	/public/free-artist
	├── album3 disc1
	│   ├── song1.mp3
	│   ├── song2.mp3
	│   └── song3.mp3
	└── album3 disc2
	    ├── song1.mp3
	    ├── song2.mp3
	    └── song3.mp3

You should now run this script twice, once for each of the directories you
moved files to. 

From `/downloading/free-artist-discography` you run

	./movenseed.sh --postwork --here ./ --there /my-music/free-artist --there /public/free-artist

Or from anywhere you run

	./movenseed.sh --postwork --here /downloading/free-artist-discography --there /my-music/free-artist --there /public/free-artist

Inside `/downloading/free-artist-discography` you should now have symbolic links
pointing towards all those .mp3 files, even though you changed the directory
structure and even renamed some of them.

	/downloads/free-artist-discography
	├── album1
	│   ├── cover.jpg
	│   ├── song1.mp3 -> /my-music/free-artist/album1 [year]/artist-album-song1.mp3
	│   ├── song2.mp3 -> /my-music/free-artist/album1 [year]/artist-album-song2.mp3
	│   ├── song3.mp3 -> /my-music/free-artist/album1 [year]/artist-album-song3.mp3
	│   └── track-list.txt
	├── album2
	│   ├── cover.jpg
	│   ├── song1.mp3 -> /my-music/free-artist/album2 [year]/artist-album-song1.mp3
	│   ├── song2.mp3 -> /my-music/free-artist/album2 [year]/artist-album-song2.mp3
	│   ├── song3.mp3 -> /my-music/free-artist/album2 [year]/artist-album-song3.mp3
	│   └── track-list.txt
	├── album3
	│   ├── cd1
	│   │   ├── song1.mp3 -> /public/free-artist/album3 disc1/song1.mp3
	│   │   ├── song2.mp3 -> /public/free-artist/album3 disc1/song2.mp3
	│   │   └── song3.mp3 -> /public/free-artist/album3 disc1/song3.mp3
	│   ├── cd2
	│   │   ├── song1.mp3 -> /public/free-artist/album3 disc2/song1.mp3
	│   │   ├── song2.mp3 -> /public/free-artist/album3 disc2/song2.mp3
	│   │   └── song3.mp3 -> /public/free-artist/album3 disc2/song3.mp3
	│   ├── cover.jpg
	│   └── track-list.txt
	├── another-txt-file.txt
	├── mns.sizes
	├── mns.sums
	├── readme.txt
	└── see-us-at-venue.txt
