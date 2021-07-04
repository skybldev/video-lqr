# video-lqr
A bash script that liquid rescales videos

*This repository was forked from my alternate GitHub account. It lives on here.*

This does not use Photoshop or GIMP, just a **Linux environment**, **FFmpeg** and **ImageMagick**. If you don't have Linux, you can install Cygwin or use WSL. (not tested on there though!)

Optionally, you can install GNU Parallel for parallelization featrues mentioned below.

### What is Seam Carving/Liquid Rescaling/Content Aware Scale?

Seam carving, which was named Content Aware Scale and made accessible by Adobe through Photoshop, is a method of image rescaling by carving "seams" around areas of (guessed) importance in order to preserve them while removing pixels on that path. It is "content-aware," thus the name. Learn more about it here: https://en.wikipedia.org/wiki/Seam_carving. It is also known as liquid rescaling. It's made its way into meme culture because of the funny ways it can change images.

Usually when you want to perform that on an image you would use Photoshop's Content Aware Scale tool. However, the algorithm for doing so is actually public and has been ported onto various other software. One of which is ImageMagick, a terminal-based, powerful image manipulation tool. (https://imagemagick.org/index.php)

### What is this?

This script automates that process, by:

1. Splitting a video into its individual frames as .png files using FFmpeg
2. Running ImageMagick's `-liquid-rescale` on all of them
3. Parsing all of the resized frames into a video (along with the audio)

The second step takes VERY long by itself, but is much, much faster than doing it in Photoshop.

Also, fair warning, *please make sure you have enough disk space to store all the frames.* A collection of individual frames as files is much bigger than the input video, and ImageMagick will resize those frames into new files, so make sure you have at least three times the size of the input video in free space.

### Documentation

#### Quick Start

*Sorry if this sounds stupid to you experienced Bash developers; I am writing this for beginners. If you have any suggestions, please create an Issue. :)*

Download the script manually or by cloning this repository. Run it using `./video-lqr.sh`. If it does not execute, make sure you have correct permissions and `chmod a+x video-lqr.sh` just to be sure.

Make sure you read the helptext first (pass `--help`) to get to know what each argument does. You will learn more from those than this Quick Start.

To convert a video, simply run:

```bash
./video.lqr -i <your input video> -r <desired output resolution>
```

...and it will start working! It will save to a video of the same name as the input, in your current directory.

To be clear(er), the resolution in `-r` can be WIDTHxHEIGHT (e.g. 1440x900) or a percentage of the input resolution (e.g. 50%) 

If you want it to save to a custom file, simply pass `-o <the output filename>`.

#### Advanced Usage

##### Processing high-framerate or very long videos

As with everything, your environment will have its limits. Your system can become less responsive if there are thousands of files in a single directory. You can reduce the amount of frames (and thus the amount of files) that will be put in the temporary directory by reducing your video's framerate or splitting it into smaller chunks.

*A frame chunking feature will be implemented soon!*

##### Parallelizing the ImageMagick process

If you want to save time, you can pass the `--parallel` option to parallelize the slow ImageMagick process using GNU Parallel.

Usually, the script will only use one thread for ImageMagick, meaning only one frame would be processesed at a time and on one core only. Parallelizing allows multiple frames to be processed at once on multiple cores, maximizing CPU usage and speeding up the process significantly.

You can set the number of jobs run (and thus threads used) by Parallel with the `--jobs` option. This is useful for allowing headroom for other programs that may be running on your system. It is advisable to have one less job than the number of cores your processor has, so your computer has enough wiggle room to maintain decent responsiveness.

### TODO

* ~~Automatically determining a video's FPS~~ (Done)
* An option to include custom audio
* ~~Multithreading the slow ImageMagick process (Using GNU Parallel possibly?)~~ (Done)
* Better output resolution notation checking
* Splitting videos into chunks using FFmpeg to avoid crippling filesystem (Very important)

### Special thanks

...to [u/kevors](https://www.reddit.com/user/kevors) for giving me a stern talking to on Reddit, giving helpful advice and suggestions (and code), and motivating me to get off my butt and actually make this script decent. :)