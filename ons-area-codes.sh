#!/bin/bash
# ------------------------------------------------------------------------------
# Script: ons-postcode-directory.sh
# Description:
#   Downloads the latest ONS postcode directory,
#   cleans up, converts selected fields to Parquet (EPSG:4326).
# ------------------------------------------------------------------------------

export LC_ALL=C  # Set locale to C for consistent sorting and character handling

# Strict mode: exit on error, undefined variables, and pipe failures
set -euo pipefail

# ------------------------------------------------------------------------------
# 1. Prepare working directory
# ------------------------------------------------------------------------------
DATA_DIR="data/ons-area-codes/pcd"  # Define main data directory path
mkdir -p "$DATA_DIR"  # Create directory if it doesn't exist (with parents)
cd "$DATA_DIR"  # Change to data directory

DOC_DIR="Documents"  # Define subdirectory name for document files
AREA_DICT="ons-area-codes-pcd.csv"  # Output filename for area codes dictionary
TEMP_FILE=$(mktemp)  # Create temporary file for intermediate processing

# ------------------------------------------------------------------------------
# 2. Download and extract the ONS postcode documents
# ------------------------------------------------------------------------------
echo
echo "Downloading and Extracting the ONS postcode documents from ArcGIS Hub..."
# Download the dataset from ArcGIS Hub
curl -L https://www.arcgis.com/sharing/rest/content/items/295e076b89b542e497e05632706ab429/data -o ons-postcode-directory.zip
# Extract the zip file ($_ represents the last argument from previous command - the zip filename)
unzip $_ "Documents/*" "User Guide/*"  # Extract only Documents and User Guide directories
# Remove the zip file after extraction to save space
rm *.zip

echo
echo "Extracting ONS area codes and names..."
# Find and process files matching the patterns for different geographic area types
for pattern in "CTRY*.csv" "RGN*.csv" "CTY*.csv" "LAD*.csv" "PFA*.csv" "MSOA*2021*.csv" "LSOA*2021*.csv" "NPARK*.csv"; do
    # Find files matching the pattern in the Documents directory
    for file in $DOC_DIR/$pattern; do
        echo "  $file"  # Print current file being processed
        # Extract first 2 columns, remove carriage returns, skip header line, remove empty lines and wrap both columns in quotes
        cut -d, -f1,2 "$file" | tr -d '\r' | tail -n +2 | grep -v '^,' | sed 's/^/"/; s/,/","/; s/$/"/' >> "$TEMP_FILE"
    done
done

echo '"L93000001","Channel Islands"' >> "$TEMP_FILE"
echo '"M83000003","Isle of Man"' >> "$TEMP_FILE"

# Sort and deduplicate (like merging dictionaries) - keep only first occurrence of each key
sort -t, -u -k1,1 "$TEMP_FILE" > "$AREA_DICT"

echo "Combined area dictionary created."
echo "  $AREA_DICT"

# Clean up temp file
rm $TEMP_FILE

# ------------------------------------------------------------------------------
# 5. Display results
# ------------------------------------------------------------------------------
echo
echo "Conversion complete. Generated files:"
ls -lh  # List files with human-readable sizes

# ------------------------------------------------------------
# 6. Return to project root
# ------------------------------------------------------------
cd - >/dev/null  # Return to previous directory, suppress output












# ------------------------------------------------------------------------------
# 1. Prepare working directory
# ------------------------------------------------------------------------------
DATA_DIR="data/ons-area-codes/uprn"  # Define main data directory path
mkdir -p "$DATA_DIR"  # Create directory if it doesn't exist (with parents)
cd "$DATA_DIR"  # Change to data directory

DOC_DIR="Documents"  # Define subdirectory name for document files
AREA_DICT="ons-area-codes-uprn.csv"  # Output filename for area codes dictionary
TEMP_FILE=$(mktemp)  # Create temporary file for intermediate processing

# ------------------------------------------------------------------------------
# 2. Download and extract the ONS postcode documents
# ------------------------------------------------------------------------------
echo
echo "Downloading and Extracting the ONS UPRN documents from ArcGIS Hub..."
# Download the dataset from ArcGIS Hub
curl -L https://www.arcgis.com/sharing/rest/content/items/ad7564917fe94ae4aea6487321e36325/data -o ons-uprn-directory.zip
# Extract the zip file ($_ represents the last argument from previous command - the zip filename)
unzip $_ "Documents/*" "User Guide/*"  # Extract only Documents and User Guide directories
# Remove the zip file after extraction to save space
rm *.zip

echo
echo "Extracting ONS area codes and names..."
# Find and process files matching the patterns for different geographic area types
for pattern in "CTRY*.csv" "RGN*.csv" "CTY*.csv" "LAD*.csv" "PFA*.csv" "MSOA*2021*.csv" "LSOA*2021*.csv" "NPARK*.csv"; do
    # Find files matching the pattern in the Documents directory
    for file in $DOC_DIR/$pattern; do
        echo "  $file"  # Print current file being processed
        # Extract first 2 columns, remove carriage returns, skip header line, remove empty lines and wrap both columns in quotes
        cut -d, -f1,2 "$file" | tr -d '\r' | tail -n +2 | grep -v '^,' | sed 's/^/"/; s/,/","/; s/$/"/' >> "$TEMP_FILE"
    done
done

# Sort and deduplicate (like merging dictionaries) - keep only first occurrence of each key
sort -t, -u -k1,1 "$TEMP_FILE" > "$AREA_DICT"

echo "Combined area dictionary created."
echo "  $AREA_DICT"

# Clean up temp file
rm $TEMP_FILE

# ------------------------------------------------------------------------------
# 5. Display results
# ------------------------------------------------------------------------------
echo
echo "Conversion complete. Generated files:"
ls -lh  # List files with human-readable sizes

# ------------------------------------------------------------
# 6. Return to project root
# ------------------------------------------------------------
cd ..  

cat pcd/ons-area-codes-pcd.csv uprn/ons-area-codes-uprn.csv | sort -t, -u -k1,1 > ons-area-codes.csv

# ------------------------------------------------------------
# 6. Return to project root
# ------------------------------------------------------------
cd - >/dev/null  # Return to previous directory, suppress output

echo
echo "Done."
