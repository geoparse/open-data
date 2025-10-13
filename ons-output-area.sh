#!/usr/bin/env bash

DATA_DIR="data/ons-output-area"

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

mkdir shp

curl https://data.cambridgeshireinsight.org.uk/sites/default/files/Output_Area_December_2011_Generalised_Clipped_Boundaries_in_England_and_Wales.zip -o shp/oa.zip

curl https://data.cambridgeshireinsight.org.uk/sites/default/files/Lower_Layer_Super_Output_Areas_December_2011_Generalised_Clipped__Boundaries_in_England_and_Wales.zip -o shp/lsoa.zip

curl https://data.cambridgeshireinsight.org.uk/sites/default/files/MSOA_EngWal_Dec_2011_Generalised_ClippedEW_0.zip -o shp/msoa.zip

unzip -d shp/ 'shp/*.zip'
rm $_

# Loop through all .shp files in a directory
for shp_file in shp/*.shp; do
    base_name=$(basename "$shp_file" .shp)
    ogr2ogr "${base_name}.parquet" "$shp_file" -unsetFid -t_srs EPSG:4326 -makevalid
done

mv L* lsoa.parquet
mv M* msoa.parquet
mv O* oa.parquet

cd ../../
