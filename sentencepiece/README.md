This directory contains the modified version of make_py_wheels.sh that is to be used for building tf_sentencepiece.

First, one has to clone the sentencepiece repository : 

git clone https://github.com/google/sentencepiece.git
cd sentencepiece
git checkout <some tag>

Then, build sentencepiece without installing it
cmake . 
make

Then, go in the tensorflow directory
cd tensorflow

copy the make_py_wheels.sh on top of the existing one, load a python module (any will do, it is multi-python), and run ./make_py_wheels.sh


