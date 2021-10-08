
cd output2_try2
for i in  1 2 3 4 5 
## the number of i's depending on how many plume_effluent.tif files were created. We will  subset in batches of 10000, so for instance, I had ~95000 .tif files, so i ran my for loop for i in 1:10

do
   printf "Starting $i \n"
   mkdir subsets/subset$i
  
   # move the tif files in batches of 10000 - NOTE CHANGE TO 10000 before running again gage
   mv `ls | head -10000` subsets/subset$i/
  
   # mosaic subset 
   cd subsets/subset$i/

    python2 /home/sgclawson/plumes/gdal_add.py -o effluent_sub$i.tif -ot Float32 plume_effluent*.tif # ALWAYS UPDATE first tif NAME to whatever you are running.. 

   printf "subset $i tif done \n"
  
   # move subset mosaic and go up
   mv effluent_sub$i.tif ../ # ALWAYS UPDATE tif NAME
   cd ../../
   
   printf "\n Ending $i \n"
done

# final mosaic
cd subsets

python2 /home/sgclawson/plumes/gdal_add.py -o mosaic_effluent.tif -ot Float32 effluent_sub*.tif # ALWAYS UPDATE tif NAME

echo "finished mosaic"