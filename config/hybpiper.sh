# https://github.com/mossmatters/HybPiper

MODULE_RUNTIME_DEPS="blast+ bbmap bwa exonerate diamond mafft samtools spades"
PACKAGE_DOWNLOAD_ARGUMENT="https://github.com/mossmatters/HybPiper/archive/refs/tags/v${VERSION:?version required}.zip"

# So that the version check for Biopython works with our local version
PATCHES="hybpiper.patch"

# manually define dependencies based on:
# https://github.com/mossmatters/HybPiper#dependencies
POST_BUILD_COMMANDS='$SCRIPT_DIR/manipulate_wheels.py --inplace --force --add_req seaborn matplotlib pebble progressbar2 scipy pandas "biopython>=1.80" psutil  -w $WHEEL_NAME && WHEEL_NAME=$(ls *.whl)'

