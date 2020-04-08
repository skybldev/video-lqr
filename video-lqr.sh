#!/usr/bin/env bash
inputFile=$1        # input file
outputFile=$2       # output file
outputRes=$3        # output resolution in WIDTHxHEIGHT
fps=$4              # fps for both input and output
useLeftoverFrames=0 # whether or not to process already split frames

# create temp dir if it doesn't exist yet
if [[ ! -d ".lqrtemp/" ]]; then
  echo ":: Creating temporary directory .lqrtemp/..."
  mkdir .lqrtemp/
fi

# ask if user wants to delete leftover files from last run if found
if [ "$(ls -A .lqrtemp/)" ]; then
  while true; do
    read -r -p ">> Leftover frames from the last run were found. Delete? [Y/n] " answer
    if [[ $answer == [yY] ]] || [ -z "$answer" ]; then
      echo ":: Deleting leftover frames..."
      rm -rf .lqrtemp/
    else
      while true; do
        read -r -p ">> Would you like to process those frames? [Y/n] " answer1
        if [[ $answer1 =~ [yY] ]] || [[ -z "$answer1" ]]; then
          echo ":: Will use leftover frames from last run."
          useLeftoverFrames=1
        else
          echo ":: Doing nothing."
          exit 0
        fi
        break
      done
    fi
    break
  done
fi

# prompt user for input file if not entered
if [ -z "$inputFile" ] && [ $useLeftoverFrames == 0 ]; then
  while true; do
    read -r -p ">> Please enter the path to the source video: " answer
    inputFile=$answer
    break;
  done
fi

# prompt user for output file if not entered
if [ -z "$outputFile" ]; then
  while true; do
    read -r -p ">> Please enter the path to the output video: " answer
    outputFile=$answer
    break;
  done
fi

# prompt user for FPS if not entered
if [ -z "$fps" ]; then
  while true; do
    read -r -p ">> Please enter source video's FPS: " answer
    echo ":: Processing $inputFile at $answer FPS."
    fps=$answer
    break;
  done
fi

# prompt user for output resolution if not entered
if [ -z "$outputRes" ]; then
  while true; do
    read -r -p ">> Please enter the desired output resolution: " answer
    outputRes=$answer
    break;
  done
fi

# split video into individual frames and extract audio
if [ $useLeftoverFrames == 0 ]; then
  echo ":: Processing $inputFile."
  echo ":: Splitting frames into .lqrtemp/ ..."
  ffmpeg -v panic -i "$inputFile" -vcodec png .lqrtemp/%05d.png
  echo ":: Extracting audio from $inputFile into .lqrtemp/.audio.aac..."
  ffmpeg -v panic -i "$inputFile" -vn -acodec copy .lqrtemp/.audio.aac
else
  echo ":: Processing frames directly from .lqrtemp/ ..."
fi

# apply lqr to the images
echo ":: Liquid resizing frames to $outputRes..."
frameCount=$(find .lqrtemp -mindepth 1 -maxdepth 1 ! -name resized | wc -l)
[[ ! -d ".lqrtemp/resized/" ]] && mkdir .lqrtemp/resized/
for file in .lqrtemp/*
  do
    if [[ ! -d $file ]]; then
      convert "$file" -liquid-rescale "$outputRes" ".lqrtemp/resized/${file##*/}"
      printf ":: Scaled %s out of %s \\r" "${file##*/}" "$frameCount"
    fi
done

# convert frames back into video
echo ":: Parsing resized frames into video..."
ffmpeg -v panic -framerate "$fps" -i .lqrtemp/resized/%05d.png ".lqrtemp/.noAudio.mp4"

# put audio on video
echo ":: Adding audio track..."
ffmpeg -i ".lqrtemp/.noAudio.mp4" -i ".lqrtemp/.audio.aac" -c:v copy -c:a aac -b:a 256k "$outputFile"

# asks user whether or not to delete work files
while true; do
  read -r -p ">> Would you like to delete the leftover frames? [Y/n] " answer
  if [[ $answer =~ [yY] ]] || [[ -z "$answer" ]]; then
    echo ":: Deleting..."
    rm -rf .lqrtemp
  else
    echo ":: Keeping files."
  fi
  break
done

echo ":: Done."
