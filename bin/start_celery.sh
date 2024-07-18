#!/bin/bash
source <projectfolder>/venv/bin/activate
cd <projectfolder>/src
exec celery -A config.celery worker --loglevel=info
