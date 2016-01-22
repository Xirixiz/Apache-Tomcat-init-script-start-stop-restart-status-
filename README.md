# Apache Tomcat init script (start|stop|restart|status)
Apache Tomcat init script.

There are a lot of Tomcat init scripts available online. I created one from multiple scripts I found on Github to fullfill my needs.
One thing I was looking for is to kill the Tomcat/Java process if the process hasn't been shutdown after x seconds.

I`m using Puppet to provision this script (removed all Puppet variables in this version) in order to place the script within the Linux /etc/init.d folder and within a folder called /opt/tomcat (owner Tomcat). 

The reason I did this is because I want someone to sudo to Tomcat and use the script directly from the /opt/tomcat folder. 
??? Why not allow this user to execute "/etc/init.d/tomcat.sh <action>" ...I had multiple personal reasons at the time I created this script :).

What the script does on top of other scripts is that it checks whetere I'm already logged on as the user "tomcat" so it doesnt use the "su <user> -c <command>" execution line, ofcourse resulting a prompt for a password (since I`m trying to su to "tomcat" while I already loggen on as the user "tomcat")

#### Notes
- CATALINA_BASE should point to CATALINA_HOME if there is only one instance of Tomcat running.

#### Pernonal notes/reminders
- update-alternatives --install "/usr/bin/java" "java" "/usr/java/latest/bin/java" 1
- update-alternatives --set java /usr/java/latest/bin/java
