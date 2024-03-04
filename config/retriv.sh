PRE_BUILD_COMMANDS='
    sed -i -e "s/faiss-cpu/faiss/" requirements.txt;
'
MODULE_RUNTIME_DEPS='cuda/11.4 faiss/1.7.3 arrow'
