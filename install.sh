#!/bin/bash
# _  _  ____  __     ___  __   _  _  ____    ____  __     _
# / )( \(  __)(  )   / __)/  \ ( \/ )(  __)  (_  _)/  \   (_)
# \ /\ / ) _) / (_/\( (__(  O )/ \/ \ ) _)     )( (  O )   _
# (_/\_)(____)\____/ \___)\__/ \_)(_/(____)   (__) \__/   (_)
#   ______   ______   ______  ______  __     __   ______   ______   ______
#  /\  ___\ /\  __ \ /\  ___\/\__  _\/\ \  _ \ \ /\  __ \ /\  == \ /\  ___\
#  \ \___  \\ \ \/\ \\ \  __\\/_/\ \/\ \ \/ ".\ \\ \  __ \\ \  __< \ \  __\
#  \/\_____\\ \_____\\ \_\     \ \_\ \ \__/".~\_\\ \_\ \_\\ \_\ \_\\ \_____\
#  \/_____/ \/_____/ \/_/      \/_/  \/_/   \/_/ \/_/\/_/ \/_/ /_/ \/_____/
#                                 __   __   __   ______   ______  ______   __       __       ______   ______
#                                /\ \ /\ "-.\ \ /\  ___\ /\__  _\/\  __ \ /\ \     /\ \     /\  ___\ /\  == \
#                               \ \ \\ \ \-.  \\ \___  \\/_/\ \/\ \  __ \\ \ \____\ \ \____\ \  __\ \ \  __<
#                               \ \_\\ \_\\"\_\\/\_____\  \ \_\ \ \_\ \_\\ \_____\\ \_____\\ \_____\\ \_\ \_\
#                               \/_/ \/_/ \/_/ \/_____/   \/_/  \/_/\/_/ \/_____/ \/_____/ \/_____/ \/_/ /_/
NOW=$(date +"%F")
LOGFILE="install-$NOW.log"

Version=$(lsb_release -r --short)
Codename=$(lsb_release -c --short)
OSArch=$(uname -m)
DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
Server_User=${SUDO_USER:-${USERNAME:-${USER}}}

PASSWD=$(whiptail --backtitle "DaunBiru Installer" --title "Authentication required" --passwordbox "Installing this software requires administrative privilege. Please authenticate to begin the installation.\n\n[sudo] Password for user $Server_User:" 12 50 3>&2 2>&1 1>&3-)
export PASSWD
ORIGPASS=`echo $PASSWD | sudo -S grep -w "$Server_User" /etc/shadow | cut -d: -f2`
export ALGO=`echo $ORIGPASS | cut -d'$' -f2`
export SALT=`echo $ORIGPASS | cut -d'$' -f3`
GENPASS=$(perl -le 'print crypt("$ENV{PASSWD}","\$$ENV{ALGO}\$$ENV{SALT}\$")')

if [ "$GENPASS" == "$ORIGPASS" ]
then
  Sudo_Pass=$ENV{PASSWD}
  echo $Sudo_Pass | sudo -S sleep 0
else
  whiptail --title 'DaunBiru Installer' --msgbox 'Invalid Password' 15 60
  exit 1
fi

monita4_src="Src/Monita4/monita4"
monita4_database="Src/Monita4/monita4.sql"
monita4_apache2_conf="Src/Monita4/monita4.conf"

talisa_src="Src/Talisa/talisa"
if [[ "$OSArch" == "x86_64" ]]; then
  talisa_node_tar="Src/Talisa/node-v6.9.4-linux-x64.tar.xz"
elif [[ "$OSArch" == "i686" ]]; then
  talisa_node_tar="Src/Talisa/node-v6.9.4-linux-x86.tar.xz"
fi
talisa_node_src="Src/Talisa/node"
talisa_passenger_tar="Src/Talisa/passenger-5.1.2.tar.gz"
talisa_apache2_conf="Src/Talisa/talisa.conf"
talisa_daemon="Src/Talisa/talisa-daemon"

monita_service_exec="Src/Monita_Service/$Codename/$OSArch/monita-service"
monita_service_lib="Src/Monita_Service/$Codename/$OSArch/libhiredis.so.0.13"
monita_service_daemon="Src/Monita_Service/monita-service"

sarasvati_exec="Src/Sarasvati/$Codename/$OSArch/sarasvati"
sarasvati_desktop="Src/Sarasvati/sarasvati.desktop"

icon="Src/dbe.png"

monita4_dependencies=(
    'apache2'
    'mysql-server'
    'redis-server'
    'php5'
    'php5-mysql'
    'php5-mcrypt'
)

talisa_dependencies=(
    'apache2'
    'ruby'
    'rake'
    'mysql-server'
    'redis-server'
    'build-essential'
    # 'nginx'
)

monita_service_dependencies=(
    'qt56base'
    'qt56websockets'
    'redis-server'
    'mysql-server'
)

sarasvati_dependencies=(
    'qt56base'
    'qt56serialport'
)

function adddate() {
    while IFS= read -r line; do
        echo "$(date +"[%Y-%m-%d %H:%M:%S]") $line"
    done
}

function update_repo() {
  echo "sudo apt-get update" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S apt-get update | adddate >> $LOGFILE 2>&1 & disown
  {
    sleep 0.1
    i="0"
    last_log=""
    while (true)
    do
      proc=$(ps aux | grep -v grep | grep -e "apt-get")
      # echo -ne "$proc \r"
      if [[ "$proc" == "" ]]; then break; fi
      # Sleep for a longer period if the database is really big
      # as dumping will take longer.
      # sleep 1
      log=$(awk '/./{line=$0} END{print line}' $LOGFILE);
      log=${log:22}
      echo -e "XXX\n$i\n$log\nXXX"
      if [[ "$log" != "$last_log" ]]; then
        if [[ $i -le 100 ]]; then i=$(expr $i + 1); fi
        last_log=$log
      fi
    done
    # If it is done then display 100%
    echo 100
    # Give it some time to display the progress to the user.
    sleep 2
  } | whiptail --title "Update Repository $OSArch $Version $Codename" --gauge "Update ..." 6 60 0
}

function install_repo_qt56() {
  if (whiptail --title 'Monita Service Installer' --yesno 'Are you want to add qt56 repository ??' --yes-button 'Yes' --no-button 'No, Another time'  10 70) then
    if [[ $Codename == "trusty" ]]; then
      echo "sudo add-apt-repository 'deb http://119.18.154.235:8077/html/repo/qt561-trusty trusty main'" | adddate >> $LOGFILE 2>&1 & disown
      echo $Sudo_Pass | sudo -S add-apt-repository 'deb http://119.18.154.235:8077/html/repo/qt561-trusty trusty main' | adddate >> $LOGFILE 2>&1 & disown
    elif [[ $Codename == "xenial" ]]; then
      echo "sudo add-apt-repository 'deb http://119.18.154.235:8077/html/repo/qt561-xenial xenial main'" | adddate >> $LOGFILE 2>&1 & disown
      echo $Sudo_Pass | sudo -S add-apt-repository 'deb http://119.18.154.235:8077/html/repo/qt561-xenial xenial main' | adddate >> $LOGFILE 2>&1 & disown
    fi
    echo $Sudo_Pass | sudo -S apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E9977759 | adddate >> $LOGFILE 2>&1 & disown
    {
      sleep 0.1
      i="0"
      last_log=""
      while (true)
      do
        proc=$(ps aux | grep -v grep | grep -e "apt-key")
        # echo -ne "$proc \r"
        if [[ "$proc" == "" ]]; then break; fi
        log=$(awk '/./{line=$0} END{print line}' $LOGFILE);
        log=${log:22}
        echo -e "XXX\n$i\n$log\nXXX"
        if [[ "$log" != "$last_log" ]]; then
          if [[ $i -le 100 ]]; then
            i=$(expr $i + 1);
          else
            i="0";
          fi
          last_log=$log
        fi
      done
      echo 100
      sleep 2
    } | whiptail --title "Add QT56 Repository" --gauge "Processing ..." 6 60 0
    update_repo
  fi
}

function check_package() {
  declare -a dependencies=("${!1}")
  # echo "${dependencies[@]}"
  for i in "${dependencies[@]}"
  do
    # echo $i
    chkPkg=$(dpkg -s $i | grep installed)
    if [ "$chkPkg" == "" ]; then
      return 0
      break
    fi
  done
  return 1
}

function install_dependencies() {
  declare -a dependencies=("${!1}")
  if [[ ${dependencies[*]} =~ $(echo '\<mysql-server\>') ]]; then
    chkPkg=$(dpkg -s mysql-server | grep installed)
    if [ "$chkPkg" == "" ]; then
      while (true)
      do
        password=$(whiptail --passwordbox "[ NEW ] Enter MySQL Server password for \"root\" : " 10 60 3>&1 1>&2 2>&3)
        if [[ $password != "" ]]; then
          password_again=$(whiptail --passwordbox "[ NEW ] Enter Again MySQL Server password for \"root\" : " 10 60 3>&1 1>&2 2>&3)
          if [[ $password == $password_again ]]; then break; fi
          whiptail --ok-button Back --msgbox "Incorrect Password" 10 30
        fi
      done
      echo $Sudo_Pass | sudo -S debconf-set-selections <<< "mysql-server mysql-server/root_password password $password"
      echo $Sudo_Pass | sudo -S debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $password_again"
    fi
  fi
  echo "sudo apt-get install -y ${dependencies[@]}" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S apt-get install -y ${dependencies[@]} | adddate >> $LOGFILE 2>&1 & disown
  {
    sleep 0.1
    i="0"
    last_log=""
    while (true)
    do
      proc=$(ps aux | grep -v grep | grep -e "apt-get")
      # echo -ne "$proc \r"
      if [[ "$proc" == "" ]]; then break; fi
      # sleep 1
      log=$(awk '/./{line=$0} END{print line}' $LOGFILE);
      log=${log:22}
      new_line="\n"
      log=${log//$new_line}
      echo -e "XXX\n$i\n$log\nXXX"
      if [[ "$log" != "$last_log" ]]; then
        # if [[ "$log" == "Preconfiguring packages ..." ]]; then break; fi
        if [[ $i -le 100 ]]; then
          i=$(expr $i + 1);
        else
          i="0";
        fi
        last_log=$log
      fi
    done
    echo 100
    sleep 2
  } | whiptail --title "Install Dependencies $OSArch $Version $Codename" --gauge "Update ..." 6 60 0
}

function change_permission_html() {
  echo "sudo chgrp -R www-data /var/www/html" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S chgrp -R www-data /var/www/html
  echo "sudo find /var/www/html -type d -exec chmod g+rx {} +" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S find /var/www/html -type d -exec chmod g+rx {} +
  echo "sudo find /var/www/html -type f -exec chmod g+r {} +" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S find /var/www/html -type f -exec chmod g+r {} +

  echo "sudo chown -R $Server_User /var/www/html/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S chown -R $Server_User /var/www/html/
  echo "sudo find /var/www/html -type d -exec chmod u+rwx {} +" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S find /var/www/html -type d -exec chmod u+rwx {} +
  echo "sudo find /var/www/html -type f -exec chmod u+rw {} +" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S find /var/www/html -type f -exec chmod u+rw {} +

  echo "sudo find /var/www/html -type d -exec chmod g+s {} +" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S find /var/www/html -type d -exec chmod g+s {} +
  echo "sudo chmod -R o-rwx /var/www/html/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S chmod -R o-rwx /var/www/html/
}

function npm_install() {
  # echo "npm --registry=http://119.18.154.235:5080 install" | adddate >> $LOGFILE 2>&1 & disown
  # npm --registry=http://119.18.154.235:5080  install | adddate >> $LOGFILE 2>&1 & disown
  echo "npm install" | adddate >> $LOGFILE 2>&1 & disown
  # npm install | adddate >> $LOGFILE 2>&1 & disown
  # npm install | adddate >> $LOGFILE 2>&1 & disown
  # npm --registry=http://119.18.154.235:5080 install
  npm install sails
  while (true)
  do
    proc=$(ps aux | grep -v grep | grep -e "npm")
    if [[ "$proc" == "" ]]; then break; fi
  done
  npm install
  # {
  #   sleep 0.1
  #   i="0"
  #   last_log=""
    while (true)
    do
      proc=$(ps aux | grep -v grep | grep -e "npm")
      # echo -ne "$proc \r"
      if [[ "$proc" == "" ]]; then break; fi
  #     log=$(awk '/./{line=$0} END{print line}' $LOGFILE);
  #     log=${log:22}
  #     echo -e "XXX\n$i\n$log\nXXX"
  #     if [[ "$log" != "$last_log" ]]; then
  #       if [[ $i -le 100 ]]; then
  #         i=$(expr $i + 1);
  #       else
  #         i="0";
  #       fi
  #       last_log=$log
  #     fi
    done
  #   echo 100
  #   sleep 2
  # } | whiptail --title "NPM Install Dependencies" --gauge "Processing ..." 6 60 0
}

function create_database() {
  if [[ "$password" == "" ]]; then
    password=$(whiptail --passwordbox "Enter MySQL Server password for \"root\" : " 10 60 3>&1 1>&2 2>&3)
  fi
  RESULT=$(mysqlshow --user=root --password=$password monita4 | grep -v Wildcard | grep -o monita4)
  if [ "$RESULT" == "" ]; then
    echo "mysql -u root -p < $DIR/$monita4_database" | adddate >> $LOGFILE 2>&1 & disown
    mysql -uroot -p${password} < $DIR/$monita4_database
    # while (true); do; proc=$(ps aux | grep -v grep | grep -e "mysql"); if [[ "$proc" == "" ]]; then break; fi; done
    # mysql -uroot -p${password} -e "CREATE DATABASE monita4 /*\!40100 DEFAULT CHARACTER SET utf8 */;"
  fi

  mysql -uroot -p${password} -e "CREATE USER monita4@localhost IDENTIFIED BY 'monita4';"
  # while (true); do; proc=$(ps aux | grep -v grep | grep -e "mysql"); if [[ "$proc" == "" ]]; then break; fi; done
  mysql -uroot -p${password} -e "GRANT ALL PRIVILEGES ON monita4.* TO 'monita4'@'localhost';"
  # while (true); do; proc=$(ps aux | grep -v grep | grep -e "mysql"); if [[ "$proc" == "" ]]; then break; fi; done
  mysql -uroot -p${password} -e "FLUSH PRIVILEGES;"
  # while (true); do; proc=$(ps aux | grep -v grep | grep -e "mysql"); if [[ "$proc" == "" ]]; then break; fi; done
}

install_monita4() {
  if (whiptail --title 'Monita4 Installer' --yesno 'Are you want to update repository ??' --yes-button 'Yes' --no-button 'No, Another time'  10 70) then
    update_repo
  fi
  install_dependencies monita4_dependencies[@]

  create_database

  echo "sudo cp -R $DIR/$monita4_src /var/www/html/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S cp -R $DIR/$monita4_src /var/www/html/

  change_permission_html

  echo "sudo cp $DIR/$monita4_apache2_conf /etc/apache2/sites-available/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S cp "$DIR/$monita4_apache2_conf" /etc/apache2/sites-available/

  clear
  port_listen=$(cat /etc/apache2/ports.conf | grep 'Listen 8066')
  if [[ "$port_listen" == "" ]]; then
    echo "Listen 8066" | sudo tee -a /etc/apache2/ports.conf
  fi

  echo "sudo a2ensite monita4" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S a2dissite monita4.conf
  echo $Sudo_Pass | sudo -S a2ensite monita4.conf
  echo "sudo service apache2 restart" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S service apache2 restart

  whiptail --title 'Monita4 Installer' --msgbox '
  Installation Complete ..
  http://localhost:8066' 15 60
}

install_talisa() {
  if (whiptail --title 'Talisa Installer' --yesno 'Are you want to update repository ??' --yes-button 'Yes' --no-button 'No, Another time'  10 70) then
    update_repo
  fi
  install_dependencies talisa_dependencies[@]

  echo "tar Jxf $DIR/$talisa_node_tar" | adddate >> $LOGFILE 2>&1 & disown
  tar Jxf $DIR/$talisa_node_tar
  # sleep 2

  echo "sudo cp -R $DIR/node/{bin,include,lib,share} /usr/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S cp -R $DIR/node/{bin,include,lib,share} /usr/
  # sleep 2

  echo "rm -rf $DIR/node" | adddate >> $LOGFILE 2>&1 & disown
  rm -rf $DIR/node/
  # sleep 2

  echo "sudo tar -xzf $DIR/$talisa_passenger_tar -C /opt/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S tar -xzf $DIR/$talisa_passenger_tar -C /opt/
  # sleep 2

  echo "PATH=/opt/passenger/bin:$PATH && export PATH" | adddate >> $LOGFILE & disown
  PATH=/opt/passenger/bin:$PATH
  sleep 2
  export PATH
  sleep 2
  echo "PATH=$PATH" | adddate >> $LOGFILE 2>&1 & disown
  sleep 2
  export PATH

  echo "cp -R $DIR/$talisa_src/ /var/www/html/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S cp -R $DIR/$talisa_src/ /var/www/html/
  # sleep 2

  change_permission_html

  echo "
  {
  	\"app_type\": \"node\",
  	\"startup_file\": \"app.js\",
  	\"environment\": \"production\",
  	\"port\": 1965,
  	\"daemonize\": true,
  	\"user\": \"$Server_User\",
  }
  " > /var/www/html/talisa/Passengerfile.json
  # sleep 2

  while (true)
  do
    server=$(whiptail --title "Server Name" --inputbox "Please input your server name ?" 10 60 192.168.57.1 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [[ $exitstatus -ne 0 ]]; then
      whiptail --title 'Talisa Installer' --msgbox 'Installation Not Complete ..' 15 60
      exit 1
    fi
    if [[ "$server" != "" ]]; then
      break
    fi
  done
  # sleep 2

  echo "
  APP_URL=http://$server:1965
  DB_REDIS=127.0.0.1

  DB_MYSQL_LOCAL_HOST=localhost
  DB_MYSQL_LOCAL_NAME=monita4
  DB_MYSQL_LOCAL_USER=monita4
  DB_MYSQL_LOCAL_PASS=monita4
  " > /var/www/html/talisa/.env
  # sleep 2

  create_database

  echo "cd /var/www/html/talisa" | adddate >> $LOGFILE 2>&1 & disown
  cd /var/www/html/talisa/

  change_permission_html

  # echo "sudo cp \"$DIR/$talisa_apache2_conf\" /etc/apache2/site-available/" | adddate >> $LOGFILE 2>&1 & disown
  # echo $Sudo_Pass | sudo -S cp "$DIR/$talisa_apache2_conf" /etc/apache2/sites-available/
  # sleep 2

  # echo "sudo a2ensite talisa" | adddate >> $LOGFILE 2>&1 & disown
  # echo $Sudo_Pass | sudo -S a2dissite talisa.conf
  # echo $Sudo_Pass | sudo -S a2ensite talisa.conf
  # # whiptail --title 'Talisa Installer' --msgbox 'Enable Site Talisa ..' 15 60
  # sleep 2
  clear
  echo "Wait ..."
  echo "sudo a2enmod proxy" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S a2enmod proxy | adddate >> $LOGFILE 2>&1 & disown
  # whiptail --title 'Talisa Installer' --msgbox 'Enable Proxy Module ..' 15 60
  sleep 2

  echo "sudo a2enmod proxy_http" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S a2enmod proxy_http | adddate >> $LOGFILE 2>&1 & disown
  # whiptail --title 'Talisa Installer' --msgbox 'Enable Proxy HTTP Module ..' 15 60
  sleep 2

  echo "sudo a2enmod headers" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S a2enmod headers | adddate >> $LOGFILE 2>&1 & disown
  # whiptail --title 'Talisa Installer' --msgbox 'Enable HEaders Module ..' 15 60
  sleep 2

  echo "sudo a2enmod rewrite" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S a2enmod rewrite | adddate >> $LOGFILE 2>&1 & disown
  # whiptail --title 'Talisa Installer' --msgbox 'Enable Rewrite Module ..' 15 60
  sleep 2

  echo "sudo service apache2 restart" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S service apache2 restart | adddate >> $LOGFILE 2>&1 & disown
  # whiptail --title 'Talisa Installer' --msgbox 'Restart Apache2 ..' 15 60
  sleep 2

  echo "sudo cp \"$DIR/$talisa_daemon\" /etc/init.d/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S cp "$DIR/$talisa_daemon" /etc/init.d/
  # whiptail --title 'Talisa Installer' --msgbox 'Copy Talisa Daemon ..' 15 60
  sleep 2

  echo "sudo chmod +x /etc/init.d/talisa-daemon" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S chmod +x /etc/init.d/talisa-daemon
  # whiptail --title 'Talisa Installer' --msgbox 'Change Mod Talisa Daemon ..' 15 60
  sleep 2

  echo "sudo chown $Server_User:$Server_User /etc/init.d/talisa-daemon" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S chown $Server_User:$Server_User /etc/init.d/talisa-daemon
  # whiptail --title 'Talisa Installer' --msgbox 'Change Owner Talisa Daemon ..' 15 60
  sleep 2

  echo "sudo update-rc.d talisa-daemon defaults" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S update-rc.d talisa-daemon defaults
  # whiptail --title 'Talisa Installer' --msgbox 'Update-rc.d for Talisa Daemon ..' 15 60
  sleep 2

  # whiptail --title 'Talisa Installer' --msgbox 'Installing NPM Dependencies ..' 15 60
  npm_install

  if (whiptail --title 'Talisa Installer' --yesno 'Are you want to run talisa-daemon now ??' --yes-button 'Yes' --no-button 'No, Another time'  10 70) then
    clear
    echo "service talisa-daemon start" | adddate >> $LOGFILE 2>&1 & disown
    service talisa-daemon start
    sleep 2
    echo "service talisa-daemon status" | adddate >> $LOGFILE 2>&1 & disown
    service talisa-daemon status
    sleep 2
  fi

  whiptail --title 'Talisa Installer' --msgbox '
  Installation Complete ..
  http://localhost:1965' 15 60
}

install_monita_service() {
  if [[ ("$Codename" != "trusty") ]]; then
    if [[ ("$Codename" != "xenial") ]]; then
      echo "This Computer : $Version $Codename $OSArch"
      echo "This script must be run on Trusty or Xenial" 1>&2
      exit 1
    fi
  fi

  if check_package monita_service_dependencies[@]; then install_repo_qt56; fi
  install_dependencies monita_service_dependencies[@]

  echo "sudo cp \"$DIR/$monita_service_exec\" /usr/local/bin/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S cp "$DIR/$monita_service_exec" /usr/local/bin/

  if [[ "$OSArch" == "x86_64" ]]; then
    echo "sudo cp \"$DIR/$monita_service_lib\" /usr/lib/x86_64-linux-gnu/" | adddate >> $LOGFILE 2>&1 & disown
    echo $Sudo_Pass | sudo -S cp "$DIR/$monita_service_lib" /usr/lib/x86_64-linux-gnu/
  elif [[ "$OSArch" == "i686" ]]; then
    echo "sudo cp \"$DIR/$monita_service_lib\" /usr/lib/i386-linux-gnu/" | adddate >> $LOGFILE 2>&1 & disown
    echo $Sudo_Pass | sudo -S cp "$DIR/$monita_service_lib" /usr/lib/i386-linux-gnu/
  fi

  echo "sudo cp \"$DIR/$monita_service_daemon\" /etc/init.d/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S cp "$DIR/$monita_service_daemon" /etc/init.d/

  echo "sudo chmod +x /etc/init.d/monita-service" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S chmod +x /etc/init.d/monita-service

  echo "sudo chown $Server_User:$Server_User /etc/init.d/monita-service" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S chown $Server_User:$Server_User /etc/init.d/monita-service

  echo "sudo update-rc.d monita-service defaults" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S update-rc.d monita-service defaults

  if (whiptail --title 'Monita Service Installer' --yesno 'Are you want to run monita-service now ??' --yes-button 'Yes' --no-button 'No, Another time'  10 70) then
    echo "sudo service monita-service start" | adddate >> $LOGFILE 2>&1 & disown
    echo $Sudo_Pass | sudo -S service monita-service start
    echo "sudo service monita-service status" | adddate >> $LOGFILE 2>&1 & disown
    echo $Sudo_Pass | sudo -S service monita-service status
  fi

  whiptail --title 'Monita Servie Installer' --msgbox 'Installation Complete ..' 15 60
}

install_sarasvati() {
  if [[ ("$Codename" != "trusty") ]]; then
    if [[ ("$Codename" != "xenial") ]]; then
      echo "This Computer : $Version $Codename $OSArch"
      echo "This script must be run on Trusty or Xenial" 1>&2
      exit 1
    fi
  fi

  if check_package sarasvati_dependencies[@]; then install_repo_qt56; fi
  install_dependencies sarasvati_dependencies[@]

  echo "sudo cp \"$DIR/$sarasvati_exec\" /usr/bin" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S cp "$DIR/$sarasvati_exec" /usr/local/bin
  echo $Sudo_Pass | sudo -S chmod 777 /usr/local/bin/sarasvati

  echo "sudo cp \"$DIR/$icon\" /usr/share/pixmaps/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S cp "$DIR/$icon" /usr/share/pixmaps/
  echo $Sudo_Pass | sudo -S chmod 777 /usr/share/pixmaps/dbe.png

  echo "sudo cp \"$DIR/$sarasvati_desktop\" /usr/share/applications/" | adddate >> $LOGFILE 2>&1 & disown
  echo $Sudo_Pass | sudo -S cp "$DIR/$sarasvati_desktop" /usr/share/applications/
  echo $Sudo_Pass | sudo -S chmod 777 /usr/share/applications/sarasvati.desktop

  whiptail --title 'Sarasvati Installer' --msgbox 'Installation Complete ..' 15 60
}

whiptail --title 'DaunBiru Installer' --msgbox 'Welcome to:
Daun Biru Software Installer
www.daunbiru.com' 15 60

OPTION=$(whiptail --title "Menu" --menu "Choose your application will be install : " 15 60 4 \
"1" "Monita4" \
"2" "Talisa" \
"3" "Monita Service" \
"4" "Sarasvati"  3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus == 0 ]; then
  echo "-------------------------------------------------------" | adddate >> $LOGFILE 2>&1 & disown
  echo "--------------------START INSTALLER--------------------" | adddate >> $LOGFILE 2>&1 & disown
  echo "-------------------------------------------------------" | adddate >> $LOGFILE 2>&1 & disown
  # echo "Your chosen option:" $OPTION
  if [ $OPTION == 1 ]; then
    # echo "Your chosen option: Monita4"
    install_monita4
  elif [ $OPTION == 2 ]; then
    # echo "Your chosen option: Talisa"
    install_talisa
  elif [ $OPTION == 3 ]; then
    # echo "Your chosen option: Monita Service"
    install_monita_service
  elif [ $OPTION == 4 ]; then
    # echo "Your chosen option: Sarasvati"
    install_sarasvati
  fi
else
  echo "You chose Cancel."
fi

echo "-------------------------------------------------------" | adddate >> $LOGFILE 2>&1 & disown
echo "---------------------END INSTALLER---------------------" | adddate >> $LOGFILE 2>&1 & disown
echo "-------------------------------------------------------" | adddate >> $LOGFILE 2>&1 & disown
