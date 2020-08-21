if [[ -n "$EBROOTGENTOO" ]]; then
    MODULE_RUNTIME_DEPS="gcc/9.3.0 limix-bgen almosthere"
else
    MODULE_RUNTIME_DEPS="gcc/7.3.0 limix-bgen almosthere"
fi
