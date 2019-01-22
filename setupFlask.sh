sudo apt-get -y update
sudo ln -sT /usr/bin/python3 /usr/bin/python
sudo apt-get -y install python3-pip
sudo ln -sT /usr/bin/pip3 /usr/bin/pip
sudo pip install flask
sudo apt-get install python-virtualenv
mkdir flaskproject
cd flaskproject
virtualenv venv
sudo apt-get -y install apache2 libapache2-mod-wsgi-py3
#create app.py file
cat <<EOT >> app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
	return 'Hello, World!'

if __name__ == "__main__":
    app.run()
EOT

#create app.wsgi
cat <<EOT >> app.wsgi
activate_this = '/home/ubuntu/flaskproject/venv/bin/activate_this.py'
with open(activate_this) as f:
	exec(f.read(), dict(__file__=activate_this))

import sys
import logging

logging.basicConfig(stream=sys.stderr)
sys.path.insert(0,"/var/www/html/flaskproject/")

from app import app as application
EOT

sudo ln -sT ~/flaskproject /var/www/html/flaskproject
sudo a2enmod wsgi

sudo sed '/DocumentRoot/a WSGIDaemonProcess flaskproject threads=5\nWSGIScriptAlias / /var/www/html/flaskproject/app.wsgi\n<Directory flaskproject>\nWSGIProcessGroup flaskproject\nWSGIApplicationGroup %{GLOBAL}\nOrder deny,allow\nAllow from all\n</Directory>\n' -i /etc/apache2/sites-enabled/000-default.conf

sudo apachectl restart


