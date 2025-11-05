#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

DATA_DIR="data/ons-country-region"

mkdir -p "$DATA_DIR"
cd $_

mkdir -p gpkg

echo "Copying downloaded GeoPackage files to $DATA_DIR/gpkg..."
cp ~/Downloads/Countries_*_Boundaries_UK_*.gpkg gpkg/
cp ~/Downloads/Regions_*_Boundaries_EN_*.gpkg gpkg/
echo

# ------------------------------------------------------------
# Convert GeoPackage files to Parquet
# ------------------------------------------------------------
echo "Converting GeoPackage files to Parquet format..."

# Loop through all .gpkg files and convert each to Parquet
for gpkg_file in gpkg/*.gpkg; do
    base_name=$(basename "$gpkg_file" .gpkg)
    echo "  Converting: $gpkg_file..."

    export CPL_LOG=/dev/null  # ignore warning and error messages 
    layer=$(ogrinfo $gpkg_file | grep Polygon | cut -d' ' -f2)
    
    if ogrinfo $gpkg_file -al -so | tail -10 | cut -d: -f1 | grep -q CTRY; then
        sql_query="SELECT CTRY24CD as country_code, CTRY24NM as country, SHAPE as geometry FROM $layer"
    else
        sql_query="SELECT RGN24CD as region_code, RGN24NM as region, SHAPE as geometry FROM $layer"
    fi

    ogr2ogr \
      -f Parquet "${base_name}.parquet" \
      "$gpkg_file" \
      -t_srs EPSG:4326 \
      -sql "$sql_query" \
      -makevalid
done

echo "Conversion complete."
echo

# ------------------------------------------------------------
# Standardize Parquet filenames
# ------------------------------------------------------------

mv Countries_*_BFC_*.parquet uk_countries_bfc.parquet
mv Countries_*_BFE_*.parquet uk_countries_bfe.parquet
mv Countries_*_BGC_*.parquet uk_countries_bgc.parquet
mv Countries_*_BSC_*.parquet uk_countries_bsc.parquet
mv Countries_*_BUC_*.parquet uk_countries_buc.parquet

mv Regions_*_BFC_*.parquet en_regions_bfc.parquet
mv Regions_*_BFE_*.parquet en_regions_bfe.parquet
mv Regions_*_BGC_*.parquet en_regions_bgc.parquet
mv Regions_*_BSC_*.parquet en_regions_bsc.parquet
mv Regions_*_BUC_*.parquet en_regions_buc.parquet

echo "All Parquet files ready in $DATA_DIR"
echo
ls -lh *.parquet

# ------------------------------------------------------------
# Return to project root
# ------------------------------------------------------------
cd - >/dev/null

