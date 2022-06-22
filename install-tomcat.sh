###
#Install Java
sudo apt-get install -y default-jdk

#cross check if java installed 
java -version

#Install and configure Tomcat

#Create a new Tomcat group 
sudo groupadd tomcat

#Create a new Tomcat user. Add this user to the Tomcat group with a home directory of /opt/tomcat. You deploy Tomcat to this directory
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

#Install Tomcat
cd /tmp 
curl -O https://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.65/bin/apache-tomcat-8.5.65.tar.gz

#Install Tomcat to the /opt/tomcat directory. Create the folder, and then open the archive
sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
sudo chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/

#Update the permissions for Tomcat by running the following commands
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r /opt/tomcat/conf
sudo chmod g+x /opt/tomcat/conf

#Create a systemd service file, so that you can run Tomcat as a service
Tomcat needs to know where you installed Java. This path is commonly referred to as JAVA_HOME
sudo update-java-alternatives -l

#Use the value from your server to create the systemd service file
sudo touch /etc/systemd/system/tomcat.service

sudo sh -c "echo '    [Unit]
    Description=Apache Tomcat Web Application Container
    After=network.target

    [Service]
    Type=forking

    Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
    Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
    Environment=CATALINA_HOME=/opt/tomcat
    Environment=CATALINA_BASE=/opt/tomcat
    Environment='\''CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'\''
    Environment='\''JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'\''

    ExecStart=/opt/tomcat/bin/startup.sh
    ExecStop=/opt/tomcat/bin/shutdown.sh

    User=tomcat
    Group=tomcat
    UMask=0007
    RestartSec=10
    Restart=always

    [Install]
    WantedBy=multi-user.target' >> /etc/systemd/system/tomcat.service"


#Modify the value of JAVA_HOME, if necessary, to match the value you found on your system. 
#You might also want to modify the memory allocation settings that are specified in CATALINA_OPTS

#Reload the systemd daemon so that it knows about your service file
sudo systemctl daemon-reload

#Start the Tomcat service
sudo systemctl start tomcat

#Verify that it started without errors
sudo systemctl status tomcat

#Enable the service file so that Tomcat automatically starts when you reboot your server
sudo systemctl enable tomcat

sudo systemctl stop tomcat


#To be able to write to the webapps folder
#sudo usermod -a -G tomcat <VM-user>
sudo chmod 777 -R /opt/tomcat/webapps/

#Clear TOMCAT_HOME/webapps.
cd /opt/tomcat/webapps
rm -R `ls`

#Add your WAR to TOMCAT_HOME/webapps (for example, /opt/tomcat/webapps/)
curl -O https://tomcat.apache.org/tomcat-6.0-doc/appdev/sample/sample.war

sudo systemctl start tomcat










