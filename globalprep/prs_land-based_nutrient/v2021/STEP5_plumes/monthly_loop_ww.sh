
# this executes all steps for creating a final, mosaiced plume raster over a series of pourpoint shapefiles 


cd /home/sgclawson/plumes

# Load ocean mask null into grass session 
r.in.gdal /home/sgclawson/grassdata/location/PERMANENT/ocean_mask_landnull.tif output='ocean'

outdir=/home/shares/ohi/git-annex/globalprep/prs_land-based_nutrient/v2021/output/au_test_N_plume

for file in /home/sgclawson/plumes/shp/*.shp ; do

    fileout=${file%.shp}_joined.tif #define output filename  
    # fileoutsub=${file%.shp}_sub$i.tif
    
    # import the pourpoint vector file into the grass session 
	v.import ${file} output='pours' --overwrite #import the file


    # # clean up any previous pour points (maybe expand these out):
    #clean_pour_point_files.sh: removes pour_point rasters and vectors from current grass session

    g.remove -f type=raster pattern=pours_*
    g.remove -f type=vector pattern=pours_*
    g.remove -f type=raster pattern=plume_effluent_*_*
   
    # code from clean_plumes.sh: removes plume rasters from current grass session (note this pattern is from OHI not MAR)

    g.list type=rast pattern=plume_pest* > plume_raster.list
    g.list type=rast pattern=plume_fert* >> plume_raster.list

    for i in `cat plume_raster.list`; do
        echo "Processing ${i}..."
        g.remove rast=$i
    done

    echo "finished cleaning out old stuff"

    # Run the python plume script - this will creat rasters in the "grass cloud"
    python2 ./plume_buffer.py pours effluent > ./plume_buffer.log

    echo "ran plumes model"

    # Export the rasters to tif files
    # sh export_plumes.sh

    ## Code below is from export_plumes.sh

    # Make output directory to export rasters in the grass cloud to
    mkdir output 
    cd output

    # Get the list of rasters (pull down from cloud into a list)
    g.list type=raster pattern=plume_effluent* > plume_raster.list

    # export the rasters from the list into the output folder
    for i in `cat plume_raster.list`; do
        echo "Processing ${i}..."
        g.region rast=$i
        r.mapcalc "plume_temp = if(isnull(${i}),0,${i})"
        r.out.gdal --overwrite input=plume_temp output=$i.tif type=Float32
        g.remove -f type=raster name=plume_temp
    done

    echo "exported invididual pourpoint rasters to output folder"

	python2 /home/sgclawson/plumes/gdal_add.py -o $fileout -ot Float32 plume_effluent*.tif #run mosaic, note you don't need output in the file path here. Note: results get put in the output folder

    echo "finished mosaic"

	mv $fileout $outdir #move the mosaic tif file to the output directory defined above

    cd /home/sgclawson/plumes

	rm -rf /home/sgclawson/plumes/output #delete output directory and everything in it 

done #end loop

#exit grass

