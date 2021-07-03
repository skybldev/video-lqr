# video-lqr
A bash script that liquid rescales videos

*This repository was forked from my alternate GitHub account. It lives on here.*

This does not use Photoshop or GIMP, just a **Linux environment**, **FFmpeg** and **ImageMagick**. If you don't have Linux, you can install Cygwin or use WSL. (not tested on there though!)

### What is Seam Carving/Liquid Rescaling/Content Aware Scale?

Seam carving, which was named Content Aware Scale and made accessible by Adobe through Photoshop, is a method of image rescaling by carving "seams" around areas of (guessed) importance in order to preserve them while removing pixels on that path. It is "content-aware," thus the name. Learn more about it here: https://en.wikipedia.org/wiki/Seam_carving. It is also known as liquid rescaling. It's made its way into meme culture because of the funny ways it can change images.

Usually when you want to perform that on an image you would use Photoshop's Content Aware Scale tool. However, the algorithm for doing so is actually public and has been ported onto various other software. One of which is ImageMagick, a terminal-based, powerful image manipulation tool. (https://imagemagick.org/index.php)

### What is this?

This script automates that process, by:

1. Splitting a video into its individual frames as .png files using FFmpeg
2. Running ImageMagick's `-liquid-rescale` on all of them
3. Parsing all of the resized frames into a video (along with the audio)

The second step takes VERY long by itself, but is much, much faster than doing it in Photoshop.

### Documentation

#### Quick Start

*Sorry if this sounds stupid to you experienced Bash developers; I am writing this for beginners. If you have any suggestions, please create an Issue. :)*

Download the script manually or by cloning this repository. Run it using `./video-lqr.sh`. If it does not execute, make sure you have correct permissions and `chmod a+x video-lqr.sh` just to be sure.

Make sure you read the helptext first (pass `--help`) to get to know what each argument does. You will learn more from those than this Quick Start.

To convert a video, simply run:

```bash
./video.lqr -i <your input video> -r <the output resolution>
```

...and it will start working! It will save to a video of the same name as the input, in your current directory. If you want it to save to a custom file, simply pass `-o <the output filename>`.

#### Advanced Usage

##### Processing high-framerate or very long videos

As with everything, your environment will have its limits. Namely, it will have an argument limit. (see yours with `getconf ARG_MAX`) This is relevant to this script because each frame of a video is an argument that counts towards that limit.

If you are working with a video that is (usually) over an hour long, or is at an absurdly high framerate, it can start to hit that limit. To avoid hitting it and increase your wiggle room, it is advisable to use a shorter temporary directory name. It is more advisable to split your video if it's very long, or decrease its framerate if it's high.

### TODO

* ~~Automatically determining a video's FPS~~ (Done)
* An option to include custom audio
* ~~Multithreading the slow ImageMagick process (Using GNU Parallel possibly?)~~ (Done)
* Better output resolution notation checking
* Splitting videos into chunks using FFmpeg to avoid hitting ARG_MAX (Messy and will do later)

### Special thanks

...to [u/kevors](https://www.reddit.com/user/kevors) for giving me a stern talking to on Reddit, giving helpful advice and suggestions (and code), and motivating me to get off my butt and actually make this script decent. :)