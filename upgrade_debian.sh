#!/bin/bash

RELEASE=$(cat /etc/issue)
LOGFILE="/var/log/debian_upgrade.log"
STATEFILE="/var/tmp/debian_upgrade_step"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

debian_apt_update(){
    log "Обновление источников..."
    apt-get update 2>&1 | tee -a "$LOGFILE" 
    if [ $? -ne 0 ]; then
      echo "Возникла ошибка, проверьте лог в $LOGFILE."
      exit 1
    fi;
}

debian_apt_upgrade(){
    apt-get dist-upgrade -y 2>&1 | tee -a "$LOGFILE" 
    apt-get -f install -y 2>&1 | tee -a "$LOGFILE" 
    apt-get autoremove -y 2>&1 | tee -a "$LOGFILE" 
    if [ $? -ne 0 ]; then
      echo "Возникла ошибка, проверьте лог в $LOGFILE."
      exit 1
    fi;
}

do_debian11_upgrade(){
  echo "[INFO] Начало обновления до Debian 11"
  log "[INFO] Начало обновления до Debian 11"
  
  if [ "$step" -eq 1 ]; then
    log "Шаг1: Проверка наличия обновлений и установка..."
    debian_apt_update
    debian_apt_upgrade
    step=2 
    echo $step >> "$STATEFILE"
  fi
  
  if [ "$step" -eq 2 ]; then
    log "Шаг 2: Обновление источников..."
    sed -i 's/buster\/updates/bullseye-security/g' /etc/apt/sources.list >> "$LOGFILE" 2>&1
    sed -i 's/buster/bullseye/g' /etc/apt/sources.list >> "$LOGFILE" 2>&1
    step=3 
    echo $step >> "$STATEFILE"
  fi
  
  if [ "$step" -eq 3 ]; then
    log "Шаг 3: Запуск полного обновления до версии 11..."
    debian_apt_update
    debian_apt_upgrade
    step=4
    echo $step >> "$STATEFILE"
  fi
  
  if [ "$step" -eq 4 ]; then
    if [ -f /var/run/reboot-required ]; then
      echo "Шаг 4: Требуется перезагрузка. Продолжить? (y/n): "
      read choice
      if [ "$choice" = "y" ]; then
        log "Шаг 4: Перезагрузка системы..."
        echo "Перезагрузка системы..."
        step=5 
        echo $step >> "$STATEFILE"
        reboot
      else
        log "Шаг 4: Перезагрузка отменена пользователем."
        exit 0
      fi
    fi
    step=5 
    echo $step >> "$STATEFILE"
  fi
}

do_debian12_upgrade(){
  echo "[INFO] Начало обновления до Debian 12"
  log "[INFO] Начало обновления до Debian 12"
    
  if [ "$step" -eq 5 ]; then
    log "Шаг5: Проверка наличия обновлений и установка..."
    debian_apt_update
    debian_apt_upgrade
    step=6
    echo $step >> "$STATEFILE"
  fi
  
  if [ "$step" -eq 6 ]; then
    log "Шаг 6: Обновление источников..."
    sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list >> "$LOGFILE" 2>&1
    step=7
    echo $step >> "$STATEFILE"
  fi
  
  if [ "$step" -eq 7 ]; then
    log "Шаг 7: Запуск полного обновления до версии 12..."
    debian_apt_update
    debian_apt_upgrade
    step=8
    echo $step >> "$STATEFILE"
  fi
  
  if [ "$step" -eq 8 ]; then
    if [ -f /var/run/reboot-required ]; then
      echo "Шаг 8: Требуется перезагрузка. Продолжить? (y/n): "
      read choice
      if [ "$choice" = "y" ]; then
        log "Шаг 8: Перезагрузка системы..."
        echo "Перезагрузка системы..."
        step=9
        echo $step >> "$STATEFILE"
        reboot
      else
        log "Шаг 8: Перезагрузка отменена пользователем."
        exit 0
      fi
    fi
    step=9
    echo $step >> "$STATEFILE"
  fi
}

if [ -f "$STATEFILE" ]; then
  log "Обновление продолжается после перезагрузки."
  step=$(tail -n 1 "$STATEFILE")
else
  log "==============================="
  step=1
  echo $step >> "$STATEFILE"
fi

echo $RELEASE | grep ' 10 '
if [ $? -eq 0 ]; then
    do_debian11_upgrade
    exit 0
fi;

echo $RELEASE | grep ' 11 '
if [ $? -eq 0 ]; then
    do_debian12_upgrade
    exit 0
fi;

echo $RELEASE | grep ' 12 '
if [ $? -eq 0 ]; then
    cat /etc/issue >> "$LOGFILE" 2>&1
    echo "Система не требует обновлений. Проверьте лог в $LOGFILE."
    exit 0
fi;

exit 0 