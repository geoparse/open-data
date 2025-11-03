#!/bin/bash

# Strict mode: exit on error, undefined variables, and pipe failures
set -euo pipefail

# ------------------------------------------------------------------------------
# 1. Prepare working directory
# ------------------------------------------------------------------------------
DATA_DIR="data/geofabrik-osm"
REGION='europe'
COUNTRY='monaco'
mkdir -p "$DATA_DIR/$COUNTRY"
cd $_

wget https://download.geofabrik.de/$REGION/$COUNTRY-latest.osm.pbf

ogrinfo $COUNTRY-latest.osm.pbf | cut -d: -f2 | cut -d' ' -f2 | tail -n +3 | while read layer; do ogr2ogr ${layer}.parquet $COUNTRY-latest.osm.pbf $layer; done

# ------------------------------------------------------------------------------
echo
echo "Extracting data. Generated files:"
ls -lh  # List files with human-readable sizes (KB, MB, GB)

# ------------------------------------------------------------------------------
# 5. Return to project root directory
# ------------------------------------------------------------------------------
cd - >/dev/null  # Return to previous directory, suppress output with /dev/null
echo
echo "Done."
