#!/bin/bash

# Create directories for landscape and portrait images
mkdir -p landscape portrait

# Loop through all JPEG images in the current directory
for image in *.jp*; do
  # Get image dimensions (Width x Height) using 'identify' from the ImageMagick package
  dimensions=$(identify -format "%[fx:w]x%[fx:h]" "$image" 2>/dev/null)
  
  # Check if 'identify' command was successful
  if [ -n "$dimensions" ]; then
    # Separate width and height into separate variables
    width=$(echo "$dimensions" | awk -F'x' '{print $1}' | tr -d ' ')
    height=$(echo "$dimensions" | awk -F'x' '{print $2}' | tr -d ' ')
    
    # Check if the image is in landscape or portrait orientation
    if [ "$width" -gt "$height" ]; then
      # Image is in landscape orientation
      echo "Copying $image to landscape/"
      cp -a "$image" landscape/
    else
      # Image is in portrait orientation
      echo "Copying $image to portrait/"
      cp -a "$image" portrait/
    fi
  else
    # Error getting image dimensions, display an error message
    echo "Error getting image dimensions for $image"
  fi
done

