PRE_BUILD_COMMANDS=$(cat <<-END
    sed -i -e 's/django==1.6.1/django>=1.6.1/' setup.py;
    sed -i -e 's/djangorestframework==2.3.9/djangorestframework>=2.3.9/' setup.py;
    sed -i -e 's/logan==0.5.9.1/logan==0.*/' setup.py;
    sed -i -e 's/gunicorn==18.0/gunicorn>=18.0/' setup.py;
    sed -i -e 's/whisper==0.9.10/whisper>=0.9.10/' setup.py;
    sed -i -e 's/dj-static==0.0.5/dj-static==0.0.*/' setup.py;
END
) # This must stay on a separate line!
