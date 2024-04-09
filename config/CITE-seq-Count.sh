PRE_BUILD_COMMANDS=$(cat <<-END
        sed -i -e 's/pytest==4.1.0/pytest~=4.1.0/' setup.py;
        sed -i -e 's/python_requires=">=3.6"/python_requires=">=3.6, >=3.10.13"/' setup.py;
END
) # This must stay on a separate line!
