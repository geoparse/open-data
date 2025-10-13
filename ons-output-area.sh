#!/usr/bin/env bash
# ============================================================
# Script: download_and_convert_ons_geographies.sh
# Purpose: Download ONS Output Area (OA), LSOA, and MSOA
#          shapefiles for England and Wales, convert to Parquet.
# ============================================================

set -euo pipefail

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

DATA_DIR="data/ons-output-area"

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

mkdir -p shp

# ------------------------------------------------------------
# Download shapefiles
# ------------------------------------------------------------
echo "Downloading ONS Output Area, LSOA, and MSOA shapefiles..."

curl https://data.cambridgeshireinsight.org.uk/sites/default/files/Output_Area_December_2011_Generalised_Clipped_Boundaries_in_England_and_Wales.zip -o shp/oa.zip

curl https://data.cambridgeshireinsight.org.uk/sites/default/files/Lower_Layer_Super_Output_Areas_December_2011_Generalised_Clipped__Boundaries_in_England_and_Wales.zip -o shp/lsoa.zip

curl https://data.cambridgeshireinsight.org.uk/sites/default/files/MSOA_EngWal_Dec_2011_Generalised_ClippedEW_0.zip -o shp/msoa.zip

echo "Downloads complete."
echo

# ------------------------------------------------------------
# Unzip shapefiles
# ------------------------------------------------------------
echo "Extracting shapefiles..."
unzip -d shp/ -o 'shp/*.zip'
rm $_
echo "Extraction complete."
echo

# ------------------------------------------------------------
# Convert shapefiles to Parquet
# ------------------------------------------------------------
echo "Converting shapefiles to Parquet format..."

# Loop through all .shp files and convert each to Parquet
for shp_file in shp/*.shp; do
    base_name=$(basename "$shp_file" .shp)

    export CPL_LOG=/dev/null  # ignore warning and error messages 
    ogr2ogr -q \
      -f Parquet "${base_name}.parquet" \
      "$shp_file" \
      -t_srs EPSG:4326 \
      -makevalid
done

echo "Conversion complete."
echo

# ------------------------------------------------------------
# Standardize Parquet filenames
# ------------------------------------------------------------

mv L* lsoa.parquet
mv M* msoa.parquet
mv O* oa.parquet

echo "All Parquet files ready in $DATA_DIR"
echo

# ------------------------------------------------------------
# Return to project root
# ------------------------------------------------------------
cd - >/dev/null
