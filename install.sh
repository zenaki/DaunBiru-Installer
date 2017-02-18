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
Version=$(lsb_release -r --short)
Codename=$(lsb_release -c --short)
OSArch=$(uname -m)
DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
Server_User=$USER
if [ "$(id -nu)" != "root" ]; then
    sudo -k
    pass=$(whiptail --backtitle "DaunBiru Installer" --title "Authentication required" --passwordbox "Installing this software requires administrative privilege. Please authenticate to begin the installation.\n\n[sudo] Password for user $Server_User:" 12 50 3>&2 2>&1 1>&3-)
    exec sudo -S -p '' "$0" "$@" <<< "$pass"
    exit 1
fi

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
  # # current_user=$USER
  # # sudo "/home/$current_user/Belajar Bash Script/install.sh"
  # cd "$DIR"
  # sudo su
  # ./install.sh
  # exit 1
fi

if [[ ("$Codename" != "trusty") ]]; then
  if [[ ("$Codename" != "xenial") ]]; then
    echo "This Computer : $Version $Codename $OSArch"
    echo "This script must be run on Trusty or Xenial" 1>&2
    exit 1
  fi
fi

adddate() {
    while IFS= read -r line; do
        echo "$(date +"[%Y-%m-%d %H:%M:%S]") $line"
    done
}

NOW=$(date +"%F")
LOGFILE="install-$NOW.log"
echo "-------------------------------------------------------" | adddate >> $LOGFILE 2>&1 & disown
echo "--------------------START INSTALLER--------------------" | adddate >> $LOGFILE 2>&1 & disown
echo "-------------------------------------------------------" | adddate >> $LOGFILE 2>&1 & disown

Version=$(lsb_release -r --short)
Codename=$(lsb_release -c --short)
OSArch=$(uname -m)

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

# "$DIR/$sarasvati_exec"
# exit 1

# cp /etc/apt/sources.list /etc/apt/sources.list-bak
# cat /etc/apt/sources.list | sed -e 's|# deb http://119.18.154.235/ubuntu hardy partner|deb http://119.18.154.235/ubuntu hardy partner|' | sed -e 's|# deb-src http://archive.canonical.com/ubuntu hardy partner|deb-src http://archive.canonical.com/ubuntu hardy partner|' > /etc/apt/sources.list-new
# echo "deb http://packages.medibuntu.org/ hardy free non-free" >> /etc/apt/sources.list-new
# mv /etc/apt/sources.list-new /etc/apt/sources.list

monita4_dependencies=(
    'apache2'
    'mysql-server'
    'redis-server'
    'php5'
    'php5-mysql'
)

talisa_dependencies=(
    'apache2'
    'ruby'
    'rake'
    'mysql-server'
    'redis-server'
    'build-essential'
    'nginx'
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

update_repo() {
  echo "apt-get update" | adddate >> $LOGFILE 2>&1 & disown
  apt-get update | adddate >> $LOGFILE 2>&1 & disown
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

install_repo_q56() {
  if (whiptail --title 'Monita Service Installer' --yesno 'Are you want to add qt56 repository ??' --yes-button 'Yes' --no-button 'No, Another time'  10 70) then
    if [[ $Codename == "trusty" ]]; then
      echo "add-apt-repository 'deb http://119.18.154.235:8077/html/repo/qt561-trusty trusty main'" | adddate >> $LOGFILE 2>&1 & disown
      add-apt-repository 'deb http://119.18.154.235:8077/html/repo/qt561-trusty trusty main' | adddate >> $LOGFILE 2>&1 & disown
    elif [[ $Codename == "xenial" ]]; then
      echo "add-apt-repository 'deb http://119.18.154.235:8077/html/repo/qt561-xenial xenial main'" | adddate >> $LOGFILE 2>&1 & disown
      add-apt-repository 'deb http://119.18.154.235:8077/html/repo/qt561-xenial xenial main' | adddate >> $LOGFILE 2>&1 & disown
    fi
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E9977759 | adddate >> $LOGFILE 2>&1 & disown
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

check_package() {
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

install_dependencies() {
  declare -a dependencies=("${!1}")
  if [[ ${dependencies[*]} =~ $(echo '\<mysql-server\>') ]]; then
    chkPkg=$(dpkg -s mysql-server | grep installed)
    if [ "$chkPkg" == "" ]; then
      while (true)
      do
        password=$(whiptail --passwordbox "Enter MySQL Server password for \"root\" : " 10 60 3>&1 1>&2 2>&3)
        if [[ $password != "" ]]; then
          password_again=$(whiptail --passwordbox "Enter Again MySQL Server password for \"root\" : " 10 60 3>&1 1>&2 2>&3)
          if [[ $password == $password_again ]]; then break; fi
          whiptail --ok-button Back --msgbox "Incorrect Password" 10 30
        fi
      done
      debconf-set-selections <<< "mysql-server mysql-server/root_password password $password"
      debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $password_again"
    fi
  fi
  echo "apt-get install -y ${dependencies[@]}" | adddate >> $LOGFILE 2>&1 & disown
  apt-get install -y ${dependencies[@]} | adddate >> $LOGFILE 2>&1 & disown
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

install_monita4() {
  if (whiptail --title 'Monita4 Installer' --yesno 'Are you want to update repository ??' --yes-button 'Yes' --no-button 'No, Another time'  10 70) then
    update_repo
  fi
  install_dependencies monita4_dependencies[@]

  password=$(whiptail --passwordbox "Enter MySQL Server password for \"root\" : " 10 60 3>&1 1>&2 2>&3)

  echo "mysql -u root -p < $DIR/$monita4_database" | adddate >> $LOGFILE 2>&1 & disown
  mysql -u root -p $password < $DIR/$monita4_database | adddate >> $LOGFILE 2>&1 & disown

  echo "cp \"$DIR/$monita4_src\" /var/www/html/" | adddate >> $LOGFILE 2>&1 & disown
  cp "$DIR/$monita4_src" /var/www/html/

  echo "cp \"$DIR/$monita4_apache2_conf\" /etc/apache2/site-available/" | adddate >> $LOGFILE 2>&1 & disown
  cp "$DIR/$monita4_apache2_conf" /etc/apache2/site-available/

  echo "a2ensite monita4" | adddate >> $LOGFILE 2>&1 & disown
  a2ensite monita4
  echo "service apache2 restart" | adddate >> $LOGFILE 2>&1 & disown
  service apache2 restart

  whiptail --title 'Monita4 Installer' --msgbox 'Installation Complete ..' 15 60
}

install_talisa() {
  if (whiptail --title 'Talisa Installer' --yesno 'Are you want to update repository ??' --yes-button 'Yes' --no-button 'No, Another time'  10 70) then
    update_repo
  fi
  install_dependencies talisa_dependencies[@]

  echo "tar Jxf $DIR/$talisa_node_tar" | adddate >> $LOGFILE 2>&1 & disown
  tar Jxf $DIR/$talisa_node_tar

  echo "cp -R $DIR/node/{bin,include,lib,share} /usr/" | adddate >> $LOGFILE 2>&1 & disown
  cp -R $DIR/node/{bin,include,lib,share} /usr/

  # echo "rm -rf $DIR/$talisa_node_src" | adddate >> $LOGFILE 2>&1 & disown
  # rm -rf $DIR/$talisa_node_src/node/

  echo "tar -xzf $DIR/$talisa_passenger_tar -C /opt/" | adddate >> $LOGFILE 2>$1 & disown
  tar -xzf $DIR/$talisa_passenger_tar -C /opt/

  echo "PATH=/opt/passenger/bin:$PATH && export PATH" | adddate >> $LOGFILE 2>&1 & disown
  PATH=/opt/passenger/bin:$PATH && export PATH

  echo "cp -R $DIR/$talisa_src/ /var/www/html/" | adddate >> $LOGFILE 2>&1 & disown
  cp -R $DIR/$talisa_src/ /var/www/html/

  echo "
  {
  	\"app_type\": \"node\",
  	\"startup_file\": \"app.js\",
  	\"environment\": \"production\",
  	\"port\": 3000,
  	\"daemonize\": true,
  	\"user\": \"$Server_User\",
  }
  " > /var/www/html/talisa/Passengerfile.json

  password=$(whiptail --passwordbox "Enter MySQL Server password for \"root\" : " 10 60 3>&1 1>&2 2>&3)

  echo "
  APP_URL=http://127.0.0.1:1337
  DB_REDIS=127.0.0.1

  DB_MYSQL_LOCAL_HOST=localhost
  DB_MYSQL_LOCAL_NAME=marine_2_new_concept
  DB_MYSQL_LOCAL_USER=root
  DB_MYSQL_LOCAL_PASS=$password
  " > /var/www/html/talisa/.env

  cd /var/www/html/talisa/
  npm --registry=http://119.18.154.235:5080/ install

  chmod 777 -R /var/www/html/talisa/

  echo "cp \"$DIR/$talisa_apache2_conf\" /etc/apache2/site-available/" | adddate >> $LOGFILE 2>&1 & disown
  cp "$DIR/$talisa_apache2_conf" /etc/apache2/site-available/

  echo "a2ensite talisa" | adddate >> $LOGFILE 2>&1 & disown
  a2ensite talisa
  echo "a2enmod proxy" | adddate >> $LOGFILE 2>&1 & disown
  a2enmod proxy
  echo "a2enmod proxy_http" | adddate >> $LOGFILE 2>&1 & disown
  a2enmod proxy_http
  echo "a2enmod headers" | adddate >> $LOGFILE 2>&1 & disown
  a2enmod headers
  echo "a2enmod rewrite" | adddate >> $LOGFILE 2>&1 & disown
  a2enmod rewrite
  echo "service apache2 restart" | adddate >> $LOGFILE 2>&1 & disown
  service apache2 restart

  echo "cp \"$DIR/$talisa_daemon\" /etc/init.d/" | adddate >> $LOGFILE 2>&1 & disown
  cp "$DIR/$talisa_daemon" /etc/init.d/

  echo "chmod +x /etc/init.d/talisa-daemon" | adddate >> $LOGFILE 2>&1 & disown
  chmod +x /etc/init.d/talisa-daemon

  echo "chown $Server_User:$Server_User /etc/init.d/talisa-daemon" | adddate >> $LOGFILE 2>&1 & disown
  chown $Server_User:$Server_User /etc/init.d/talisa-daemon

  echo "update-rc.d talisa-daemon defaults" | adddate >> $LOGFILE 2>&1 & disown
  update-rc.d talisa-daemon defaults

  if (whiptail --title 'Talisa Installer' --yesno 'Are you want to run talisa-daemon now ??' --yes-button 'Yes' --no-button 'No, Another time'  10 70) then
    echo "service talisa-daemon start" | adddate >> $LOGFILE 2>&1 & disown
    service talisa-daemon start
    echo "service talisa-daemon status" | adddate >> $LOGFILE 2>&1 & disown
    service talisa-daemon status
  fi

  whiptail --title 'Talisa Installer' --msgbox 'Installation Complete ..' 15 60
}

install_monita_service() {
  if check_package monita_service_dependencies[@]; then install_repo_q56; fi
  install_dependencies monita_service_dependencies[@]

  echo "cp \"$DIR/$monita_service_exec\" /usr/local/bin/" | adddate >> $LOGFILE 2>&1 & disown
  cp "$DIR/$monita_service_exec" /usr/local/bin/

  if [[ "$OSArch" == "x86_64" ]]; then
    echo "cp \"$DIR/$monita_service_lib\" /usr/lib/x86_64-linux-gnu/" | adddate >> $LOGFILE 2>&1 & disown
    cp "$DIR/$monita_service_lib" /usr/lib/x86_64-linux-gnu/
  elif [[ "$OSArch" == "i686" ]]; then
    echo "cp \"$DIR/$monita_service_lib\" /usr/lib/i386-linux-gnu/" | adddate >> $LOGFILE 2>&1 & disown
    cp "$DIR/$monita_service_lib" /usr/lib/i386-linux-gnu/
  fi

  echo "cp \"$DIR/$monita_service_daemon\" /etc/init.d/" | adddate >> $LOGFILE 2>&1 & disown
  cp "$DIR/$monita_service_daemon" /etc/init.d/

  echo "chmod +x /etc/init.d/monita-service" | adddate >> $LOGFILE 2>&1 & disown
  chmod +x /etc/init.d/monita-service

  echo "chown $Server_User:$Server_User /etc/init.d/monita-service" | adddate >> $LOGFILE 2>&1 & disown
  chown $Server_User:$Server_User /etc/init.d/monita-service

  echo "update-rc.d monita-service defaults" | adddate >> $LOGFILE 2>&1 & disown
  update-rc.d monita-service defaults

  if (whiptail --title 'Monita Service Installer' --yesno 'Are you want to run monita-service now ??' --yes-button 'Yes' --no-button 'No, Another time'  10 70) then
    echo "service monita-service start" | adddate >> $LOGFILE 2>&1 & disown
    service monita-service start
    echo "service monita-service status" | adddate >> $LOGFILE 2>&1 & disown
    service monita-service status
  fi

  whiptail --title 'Monita Servie Installer' --msgbox 'Installation Complete ..' 15 60
}

install_sarasvati() {
  if check_package sarasvati_dependencies[@]; then install_repo_q56; fi
  install_dependencies sarasvati_dependencies[@]

  echo "cp \"$DIR/$sarasvati_exec\" /usr/bin" | adddate >> $LOGFILE 2>&1 & disown
  cp "$DIR/$sarasvati_exec" /usr/local/bin
  chmod 777 /usr/local/bin/sarasvati

  echo "cp \"$DIR/$icon\" /usr/share/pixmaps/" | adddate >> $LOGFILE 2>&1 & disown
  cp "$DIR/$icon" /usr/share/pixmaps/
  chmod 777 /usr/share/pixmaps/dbe.png

  echo "cp \"$DIR/$sarasvati_desktop\" /usr/share/applications/" | adddate >> $LOGFILE 2>&1 & disown
  cp "$DIR/$sarasvati_desktop" /usr/share/applications/
  chmod 777 /usr/share/applications/sarasvati.desktop

  whiptail --title 'Sarasvati Installer' --msgbox 'Installation Complete ..' 15 60
}

whiptail --title 'Installer' --msgbox 'Welcome to:
Daun Biru Software Installer
www.daunbiru.com' 15 60

OPTION=$(whiptail --title "Menu" --menu "Choose your application will be install : " 15 60 4 \
"1" "Monita4" \
"2" "Talisa" \
"3" "Monita Service" \
"4" "Sarasvati"  3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus == 0 ]; then
  echo "Your chosen option:" $OPTION
  if [ $OPTION == 1 ]; then
    echo "Your chosen option: Monita4"
    install_monita4
  elif [ $OPTION == 2 ]; then
    echo "Your chosen option: Talisa"
    install_talisa
  elif [ $OPTION == 3 ]; then
    echo "Your chosen option: Monita Service"
    install_monita_service
  elif [ $OPTION == 4 ]; then
    echo "Your chosen option: Sarasvati"
    install_sarasvati
  fi
else
  echo "You chose Cancel."
fi

echo "-------------------------------------------------------" | adddate >> $LOGFILE 2>&1 & disown
echo "---------------------END INSTALLER---------------------" | adddate >> $LOGFILE 2>&1 & disown
echo "-------------------------------------------------------" | adddate >> $LOGFILE 2>&1 & disown
