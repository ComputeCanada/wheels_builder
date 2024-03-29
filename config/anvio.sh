PACKAGE_DOWNLOAD_ARGUMENT=https://github.com/merenlab/anvio/archive/refs/tags/v${VERSION:?version required}.zip
PRE_BUILD_COMMANDS=$(cat <<-END
        sed -i -e 's/pandas==1.4.4/pandas~=1.4.1/' requirements.txt;
        sed -i -e 's/scikit-learn==1.2.2/scikit-learn~=1.2.1/' requirements.txt;
        sed -i -e '29i \  \  python_requires="==3.10.*",' setup.py;
END
) # This must stay on a separate line!


