# the patch is only valid between 0.3.2 and 0.2.23 since those version checked for the equinox version.
if [[ $(translate_version $VERSION) -le $(translate_version '0.3.2') && $(translate_version $VERSION) -ge $(translate_version '0.2.23') ]]; then
	PATCHES='jaxtyping-fix_version_parsing.patch'
fi
