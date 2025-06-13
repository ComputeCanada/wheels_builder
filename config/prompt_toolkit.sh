if [[ $(translate_version $VERSION) -ge $(translate_version '3.0.51')  ]]; then
	PATCHES='prompt_toolkit-remove_local_version.patch'
fi
