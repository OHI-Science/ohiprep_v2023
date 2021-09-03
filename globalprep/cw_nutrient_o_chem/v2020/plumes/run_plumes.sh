##################################
#
#   Re-wrote by Cascade Tuholske (cascade.tuholske@gmail.com)
#   June 2020
#
#   I rewrote the plume work flow for ease of use for the next person.
#   Each run (treatedal N, treated, open, & septic) will require updated
#   directories and input pourpoint file names.
#
#   Use /wastewater/data/interim/ocean_masks/ocean_mask_landnull.tif
#   for plumes otherwise it will plume effluents inland for some reason
#   I do not fully understand. 
#
#   This gets executed by run_all.sh
#   Be sure to update all file paths and names before executing run_all.sh.
#   
##################################

#!/bin/bash 

# Move the ocean mask null file to GRASS dir

# make a dir to write tifs
mkdir ./output

# # clean up any previous pour points:
sh clean_pour_point_files.sh

# clean up any previous pour points:
sh clean_plumes.sh

# Run the plume model
python2 plume_buffer.py pours effluent > ./plume_buffer.log

# Export the rasters to tif files
sh export_plumes.sh

## Code below is from export_plumes.sh

# Make export list
mkdir output 
cd output
rm *.*

# Get the list of rasters
g.list type=raster pattern=plume_effluent* > plume_raster.list

# export the rasters 
for i in `cat plume_raster.list`; do
  echo "Processing ${i}..."
  g.region rast=$i
  r.mapcalc "plume_temp = if(isnull(${i}),0,${i})"
  r.out.gdal --overwrite input=plume_temp output=$i.tif type=Float32
  g.remove -f type=raster name=plume_temp
done
