PRE_BUILD_COMMANDS='
    sed -i -e "s/faiss-cpu/faiss/" requirements.txt;
'
MODULE_RUNTIME_DEPS='cuda faiss arrow'
