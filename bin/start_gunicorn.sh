#!/bin/bash
source <projectfolder>/venv/bin/activate
exec gunicorn -c "<projectfolder>/src/gunicorn_config.py" config.wsgi