# video-lqr
A batch script that liquid rescales videos

*This repository was forked from my alternate GitHub account.*

This does not use Photoshop or GIMP, just a **Linux environment**, **ffmpeg** and **imagemagick**. If you don't have Linux, you can install cygwin or use WSL (not tested on there though!).

### What is Seam Carving/Liquid Rescaling/Content Aware Scale?

Seam carving, which was named Content Aware Scale and made accessible by Adobe through Photoshop, is a method of image rescaling by carving "seams" around areas of (guessed) importance in order to preserve them while removing pixels on that path. It is "content-aware," thus the name. Learn more about it here: https://en.wikipedia.org/wiki/Seam_carving. It is also known as liquid rescaling. It's made its way into meme culture because of the funny ways it can change images.

Usually when you want to perform that on an image you would use Photoshop's Content Aware Scale tool. However, the algorithm for doing so is actually public and has been ported onto various other software. One of which is ImageMagick, a terminal-based, powerful image manipulation tool. (https://imagemagick.org/index.php) It has implemented seam carving. 

### What is this?

I have written a script that automates that process, by:

1. Splitting a video into its individual frames as .png files using ffmpeg
2. Running imagemagick's `-liquid-rescale` on all of them
3. Parsing all of the resized frames into a video (along with the audio)

The second step takes VERY long by itself, but is much, much faster than doing it in Photoshop. 

### Documentation

#### Basic Usage

In order to use the script, place it into the folder where you want it to work in. Preferrably one with the source video in it. After that, simply run the script using `./video-lqr.sh`. The script is interactive when used without arguments, so it will ask you for all the information it needs:

1. Source video
2. Output video<br>
   *The source and output video are self explanatory, but you will not be able to tab-complete due to the nature of bash.*
3. Frames per second<br>
   *Since the program is not able to determine the source video's FPS (yet), you will have to enter it manually. You can find it using VLC's metadata information feature, or `ffprobe`.*
4. Output resolution<br>
   *This is the resolution to which you want to scale each of the frames. It can either be `WITDHxHEIGHT` <sup>e.g. 1600x900</sup> or a percentage of the original resolution.*

After you enter said information, it will start working. It will usually take a while to convert all the frames.

When it finishes creating the new video, it will ask if you want to delete the frames and other files it created during the process. Saying no will keep those files if you want to use them later.

#### Advanced Usage

##### Arguments

This script supports arguments in a specific order.

`./video-lqr.sh [input] [output] [outputRes] [fps]

* **[input]** path to input video
* **[output]** path to output video
* **[outputRes]** a `WIDTHxHEIGHT` or percentage of the source resolution
* **[fps]** the fps of the source video

If none are entered then the script will act interactively.

##### Reusing Frames

The script creates a temporary directory at startup if it doesn't exist. If files are found in it, it will ask whether or not it should delete the files, and if not, whether or not to process those files. If you choose yes to processing those files, it will skip the initial steps of splitting the video into individual frames and will immediately start processing the frames of the previous source video.

This works granted the frames from the previous run have not been deleted.

### Upcoming Features

* Automatically determining a video's FPS
* An option to include custom audio
