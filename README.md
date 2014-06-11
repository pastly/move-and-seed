# INTRO

This is a handy little bash script that allows you to move torrented files around without disrupting your ability to seed them.

Please report bugs at the [issue tracker](https://bitbucket.org/pointychimp/move-and-seed/issues).

If you like this and find it useful, consider sending a few bitcents my way: 17wNska6TeMDYeDGzzv26sExXP8FAKHGQ7.

# USAGE

This script will help you symbolically link files after moving/renaming
back into the directory you torrenting them into for continued seeding.
It should be run before you move/rename, and then once again afterwards.

The inspiration for this script came from torrenting lots of Linux ISOs
and wanting to continue seeding and supporting them while also 
reorganizing them elsewhere on the computer.

The commands are as follows.

	./mns.sh example
	             Prints out a full example of how this script
	             can be used. It pipes the text through "less"
	             as there is a lot.

	./mns.sh prework <dir>
				 This should be run before moving.

				 Recursively hashes all the files in <dir>.
				 A file in <dir> will be created containing
				 all the hashes. This will take a long time
				 for large directories!

	./mns.sh postwork <dir1> <dir2>
				 This should be run after moving and can be run
				 multiple times for multiple <dir2>'s.

				 Here, <dir1> should be the same as <dir> from 
				 prework. <dir2> should be where things were   
				 moved. <dir1> can still contain anything you  
				 didn't want to move and must contain that hash 
				 file generated in the prework.

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

You need to copy the script to wherever you will be using it. From inside
`/downloads/free-artist-discography`, you will run
	
	./mns.sh prework ./

Or from anywhere you will run
	
	./mns.sh prework /downloads/free-artist-discography

Once finished (this could take a long time if the albums are very large), a new
file will be in `/downloads/free-artist-discography` containing a list of all the
files and their hashes. You are now free to move any of the files and folders 
to whever you want on the filesystem. 

Let's say you personally like album1 and album2, so you put it in a directory
to be later synced with your mp3 player. Album3 isn't so good, but your
brother has bad taste in music so he likes it. You put it in a public folder so
he can access it.

### POST WORK 

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

You should now run this script twice, once for each of the directories you
moved files to. 

From `/downloading/free-artist-discography` you run

	./mns.sh postwork ./ /my-music/free-artist
	./mns.sh postwork ./ /public/free-artist

Or from anywhere you run

	./mns.sh postwork /downloading/free-artist-discography /my-music/free-artist
	./mns.sh postwork /downloading/free-artist-discography /public/free-artist

Inside `/downloading/free-artist-discography` you should now have symbolic links
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

### WORD OF WARNING

This script works by matching hashes; therefore, you need to be careful about
which directories you choose for the post work. You want to get as close to the
files as possible to avoid having to digest files that aren't related to the
torrent. Using the above example, if you have lots of other artists in the
`/my-music` directory, you would not want to use
	
	./mns.sh /downloading/free-artist-discography /my-music

as it would digest ever single file in `/my-music` and potentially take forever.
Similarly, if you put the torrented music files in the same directory as
unrelated files, you will end up digesting the unrelated files. There's nothing
wrong with this, other than you will have an unavoidable waste of time if there
is lots of large unrelated files. 