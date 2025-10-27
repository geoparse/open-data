#!/bin/bash
# ------------------------------------------------------------------------------
# Script: ons-postcode-directory.sh
# Description:
#   Downloads the latest ONS postcode directory,
#   cleans up, converts selected fields to Parquet (EPSG:4326).
# ------------------------------------------------------------------------------

set -euo pipefail  # Exit on error, undefined var, or failed pipe instead of continuing silently.

# ------------------------------------------------------------------------------
# 1. Prepare working directory
# ------------------------------------------------------------------------------
DATA_DIR="data/ons-postcode-directory"
mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

# ------------------------------------------------------------------------------
# 2. Download and extract the Code-Point Open dataset
# ------------------------------------------------------------------------------
echo
echo "Downloading the latest ONS postcode directory dataset from ArcGIS Hub..."

csv_file="ons-postcode-directory.csv"
curl -L https://open-geography-portalx-ons.hub.arcgis.com/api/download/v1/items/2182d12973974897ab386222f0e0de81/csv?layers=1 -o $csv_file
echo

# ------------------------------------------------------------------------------
# 3. Convert CSV to Parquet using DuckDB
# ------------------------------------------------------------------------------

parquet_file="${csv_file%.*}.parquet"
echo
echo "Converting CSV to Parquet using DuckDB..."
duckdb -c "
COPY (
  SELECT
    PCDS as postcode,
    DOINTR as intr_date,
    DOTERM as term_date,
    USRTYPIND as user_type,
    CTRY25CD as country,
    RGN25CD as region, 
    CTY25CD as county,
    PFA23CD as police_force, 
    MSOA21CD as msoa, 
    LSOA21CD as lsoa, 
    OA21CD as oa, 
    RUC21IND as rural_urban,
    NPARK16CD as national_park,
    CASE WHEN LAT > 90 THEN NULL ELSE LAT END AS lat,
    CASE WHEN LAT > 90 THEN NULL ELSE LONG END AS lon
  FROM read_csv_auto('$csv_file', sample_size=-1)
) TO '$parquet_file';
"

gzip *.csv

# ------------------------------------------------------------------------------
# 4. Display results
# ------------------------------------------------------------------------------
echo
echo "Conversion complete. Generated files:"
ls -lh

# ------------------------------------------------------------------------------
# 5. Return to root directory
# ------------------------------------------------------------------------------
cd $_
echo
echo "Done."

