# Automation

## Clear_migrations
Standalone script for Django projects.
Takes additional arg -p <path> if there is some other path to your apps folder other than "apps"
Then walks through all dirs inside and deletes all migration files.

## Startup
Needed everywhere to replace docker on systemd units. Initially was made for Django project.
Considers that you have src folder for a project, gunicorn_config.py inside and two .sh scripts for project itself and a celery for it in "/bin" folder near root directory.
("bin" folder and script examples are in this repo too)
Before running, ensure that you have database set up and .env configured.
Basically makes your project fly, from writing units to makemigrations and collectstatic.
**I suppose you'll need to personalise the script a bit**.
Should harmlessly skip through all steps that couldn't be completed.

## Initial
Configures base you need for python development.
Accepts [-f] [-s] [-n] [-h] [-u] [-p [version]] flags:
- -s configures SSH (make sure you know what you're doing)
- -n gets and configures neovim
- -p [version] makes altinstall of python of specific version or latest (i.e. -p 3.12.1)
- -u updates && upgrades system and installs basic packages
- -f makes all but python
- -h prints help message
You need your id_rsa.pub file in root directory for ssh configuration.
