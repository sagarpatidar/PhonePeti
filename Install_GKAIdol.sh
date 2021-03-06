#!/bin/bash

if [ `id -u` -ne 0 ]
then
	echo "ERROR: The script mus be run as root"
	exit -1
fi

#Setting tmp as Working Directory
cd /tmp

#Create Directory
rm -f PhonePeti
mkdir PhonePeti
cd PhonePeti

#Install Dependencies
sudo apt-get -y install sox mysql-server apache2 libapache2-mod-wsgi python-mysqldb libmysqlclient-dev git-core

#Downloading Django
sudo wget http://www.djangoproject.com/m/releases/1.4/Django-1.4.tar.gz

#Installing Django
tar xzvf Django-1.4.tar.gz
cd Django-1.4
sudo python setup.py install

#Code for Git Clone
sudo apt-get -y -v install git-core
git clone https://github.com/MePiyush/PhonePeti.git

#Create the following Folder Structures
mkdir -p /usr/local/phonepeti/GKAIdol/media/recordings
mkdir -p /usr/local/phonepeti/GKAIdol/logs

#Change File Permissions
chmod -R a+w /usr/local/phonepeti/GKAIdol/media
chmod -R a+w /usr/local/phonepeti/GKAIdol/logs
chmod +x /usr/local/phonepeti/GKAIdol/GKAIdol.agi

#Copy Voice Applications
cp -r PhonePeti/VoiceApplications/* /usr/local/phonepeti/

#Moving Templates
rm -r /usr/local/phonepeti/Templates/*
mkdir -p /usr/local/phonepeti/Templates
mv -r /usr/local/phonepeti/GKAIdol/Templates/* /usr/local/phonepeti/Templates

#Create MySQL Database
mysql -uroot -pjunoon -e "create database PhonePeti"

#Populating Database
cd /usr/local/phonepeti/
python manage.py syncdb

#Creating Database Entries
mysql -uroot -pjunoon -e "INSERT INTO PhonePeti.PhonePeti_application (name, description) VALUES ('GKAIdol', 'Application for Recording & Voting songs')"
mysql -uroot -pjunoon -e "INSERT INTO PhonePeti.PhonePeti_appinstance (app_id, startTime, endTime, options) VALUES ('1', NULL, NULL, 'GKAIdol Application')"

#Editing Apache configuration
sudo echo -e "WSGIScriptAlias / /usr/local/phonepeti/VoiceApplications/wsgi.py\n
WSGIPythonPath /usr/local/phonepeti\n
<Directory /usr/local/phonepeti/VoiceApplications>\n
<Files wsgi.py>\n
Order deny,allow\n
Allow from all\n
</Files>\n
</Directory>\n" >> /etc/apache2/httpd.conf

#Restart Apache
/etc/init.d/apache2 restart
