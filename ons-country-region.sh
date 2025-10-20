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

DATA_DIR="data/ons-country-region"

mkdir -p "$DATA_DIR"
cd $_

mkdir -p gpkg

mv ~/Downloads/Countries_*_Boundaries_UK_*.gpkg gpkg/
mv ~/Downloads/Regions_*_Boundaries_EN_*.gpkg gpkg/



# ------------------------------------------------------------
# Convert GeoPackage files to Parquet
# ------------------------------------------------------------
echo "Converting GeoPackage files to Parquet format..."

# Loop through all .gpkg files and convert each to Parquet
for gpkg_file in gpkg/*.gpkg; do
    base_name=$(basename "$gpkg_file" .gpkg)
    echo "  Converting: $gpkg_file..."

    export CPL_LOG=/dev/null  # ignore warning and error messages 
    ogr2ogr -q \
      -f Parquet "${base_name}.parquet" \
      "$gpkg_file" \
      -t_srs EPSG:4326 \
      -makevalid
done

echo "Conversion complete."
echo


# ------------------------------------------------------------
# Standardize Parquet filenames
# ------------------------------------------------------------

mv Countries_*_BFC_*.parquet countries_bfc.parquet
mv Countries_*_BFE_*.parquet countries_bfe.parquet
mv Countries_*_BGC_*.parquet countries_bgc.parquet
mv Countries_*_BSC_*.parquet countries_bsc.parquet
mv Countries_*_BUC_*.parquet countries_buc.parquet

mv Regions_*_BFC_*.parquet regions_bfc.parquet
mv Regions_*_BFE_*.parquet regions_bfe.parquet
mv Regions_*_BGC_*.parquet regions_bgc.parquet
mv Regions_*_BSC_*.parquet regions_bsc.parquet
mv Regions_*_BUC_*.parquet regions_buc.parquet

echo "All Parquet files ready in $DATA_DIR"
echo
ls -lh *.parquet

# ------------------------------------------------------------
# Return to project root
# ------------------------------------------------------------
cd - >/dev/null

