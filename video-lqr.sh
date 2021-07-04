#!/usr/bin/bash
input=""            # input video
output=""           # output video

outputRes=""        # output resolution in WIDTHxHEIGHT
fps=0               # fps for both input and output
tempDir=".lqrtemp/" # temporary directory to store frames and work files
keepFrames=0        # whether or not to delete frames upon finishing
jobs=4              # max jobs to run at the same time
parallel=0          # whether or not to parallelize the process

err () {
  printf '!! %s\n' "$1"
}

warn () {
  printf '!: %s\n' "$1"
}

ok () {
  printf ':: %s\n' "$1"
}

addCasSuffix () {
  name=${1%%.*} # Get name without extension
  ext=${1#*.}   # Get file extension

  echo "$name-cas.$ext" # Add "-cas" to the end of the name
}

# -- Process options --

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "video-lqr - a bash script that liquid rescales videos"
      echo " "
      echo "video-lqr [options]"
      echo " "
      echo "options:"
      echo "-i, --input             Input video."
      echo "-o, --output            Output video."
      echo "-h, --help              Show this help."
      echo "-r, --resolution SIZE   Specify the resolution of the output. Can be"
      echo "                        WIDTHxHEIGHT or a percentage of the input's resolution."
      echo "-f, --framerate FPS     Specify a custom framerate."
      echo "--temp-directory PATH   Specify a directory to store temporary files in."
      echo "--keep-frames           Keep frames upon finishing."
      echo "--parallel              Enables parallel processing using GNU Parallel. This"
      echo "                        often makes the ImageMagick part of the process much"
      echo "                        faster depending on how many cores your processor has."
      echo "-j, --jobs JOBS         Specify the jobs GNU Parallel runs concurrently."
      exit 0
      ;;
    -i|--input)
      shift
      input=$1
      shift
      ;;
    -o|--output)
      shift
      output=$1
      shift
      ;;
    -r|--resolution)
      shift
      outputRes=$1
      shift
      ;;
    -f|--framerate)
      shift
      fps=$1
      shift
      ;;
    --temp-directory)
      shift
      tempDir=$1
      shift
      ;;
    --keep-frames)
      keepFrames=1
      shift
      ;;
    --parallel)
      parallel=1
      shift
      ;;
    -j|--jobs)
      shift
      jobs=$1
      shift
      ;;
    *)
      err "Unrecognized option $1."
      exit 1
      break
      ;;
  esac
done

# -- Check stuff --

# Check input file
if [ "$input" = "" ]; then
  err "Please provide input file with -i INPUT."
  exit 1
elif [ -d "$input" ]; then
  # TODO: accept directory of frames if supplied one
  err "Input cannot be a directory."
  exit 1
elif ! [ -a "$input" ]; then
  err "Invalid input path."
  exit 1
else
  ok "Using $input"
fi

# Check output path
if [ "$output" = "" ]; then
  output=$(basename "$input")
elif [ -d "$output" ]; then
  inputBase=$(basename "$input")                # Get input's basename
  output=${output$/}                            # Trim trailing slash from output
  output="$output/$(addCasSuffix "$inputBase")" # Put output file in directory
fi

if [ "$(realpath "$input")" = "$(realpath "$output")" ]; then
  output=$(addCasSuffix "$output")
fi

ok "Will save to $output"

# Check output resolution
if [ "$outputRes" = "" ]; then
  err "Please provide output resolution with -s RESOLUTION."
  exit 1
else
  ok "Output resolution set to $outputRes"
fi

# Determine framerate
if [ "$fps" -lt 0 ]; then
  err "Invalid framerate."
  exit 1
elif [ "$fps" = 0 ]; then
  # Thank you kevors for the command.
  ffmpegOut=$(ffprobe \
    -v error \
    -select_streams v \
    -show_entries stream=r_frame_rate \
    -of default=nw=1:nk=1 \
    "$input")

  if [ $? = 1 ]; then
    err "FFmpeg errored above!"
    exit 1
  fi

  fps=$((ffmpegOut))
  ok "Determined ${fps} FPS from input."
else
  ok "Processing at $fps FPS."
fi

# Trim trailing slash from tempDir path
tempDir=${tempDir%/}

# Create temp dir if it doesn't exist yet
if ! [ -d "$tempDir" ]; then
  warn "Creating temporary directory $tempDir..."
  mkdir "$tempDir"
fi

# Check if GNU Parallel is installed and maxthreads if --parallel is passed
if [ $parallel = 1 ]; then
  command -v "parallel" > /dev/null

  if [ $? = 1 ]; then
    err "GNU Parallel was not found on this system. Exiting."
    exit 1
  fi

  if [ "$jobs" -le 0 ]; then
    err "Job count must be above 0."
    exit 1
  fi
fi

# -- Actual process --

# Error out if leftover files from last run are found, otherwise split
if [ "$(find "$tempDir" -mindepth 1 -print -quit)" ]; then # Passes if non-empty
  err "Leftover files found. Exiting."
  exit 1
else
  ok "Splitting frames into $tempDir..."

  # FFmpeg expands it internally, not the shell
  ffmpeg -v panic -i "$input" -vcodec png "$tempDir/%05d.png"
fi

# Check if resized directory exists
if ! [ -d "$tempDir/resized" ]; then
  mkdir "$tempDir/resized"
fi

# Apply lqr to the images
if [ $parallel = 0 ]; then
  ok "Liquid resizing frames to $outputRes..."

  mogrify -monitor -path "$tempDir/resized/" -liquid-rescale "$outputRes!" "$tempDir/*.png"
else
  ok "Liquid resizing frames to $outputRes... (Parallelizing to up to $jobs jobs)"

  find "$tempDir" -maxdepth 1 -type f -name "*.png" | \
    parallel -k -j "$jobs" mogrify -monitor -path "$tempDir/resized/" -liquid-rescale "$outputRes!" "{}"
fi

if [ $? = 1 ]; then
  err "ImageMagick errored above!"
  exit 1
fi

# Finalize video
ok "Parsing frames and adding audio to video..."
  #-v error \
ffmpeg \
  -framerate "$fps" \
  -i "$tempDir/resized/%05d.png" \
  -i "$input" \
  -map 0:v:0 \
  -map 1:a:0 \
  "$output"

# Cleanup if needed
if [ $keepFrames = 1 ]; then
  ok "Keeping all frames."
else
  ok "Cleaning up..."
  rm -rf "$tempDir"
fi

ok "Done."