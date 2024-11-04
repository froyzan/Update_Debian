# Upgrade Debian 10 to 12
Этот скрипт предназначен для автоматизации процесса обновления операционной системы Debian с версии 10 до 12. Он выполняет обновление пакетов, изменение источников и перезагрузку системы при необходимости.

Скрипт выполняет следующие шаги:
```html
  Проверяет текущую версию Debian.
  Обновляет источники и пакеты.
  Изменяет репозитории в файле /etc/apt/sources.list для перехода на новую версию.
  Выполняет перезагрузку системы, если это необходимо.
  Логирует все действия в файл /var/log/debian_upgrade.log.
```
## Usage/Запуск
```bash
  chmod +x upgrade_debian.sh
  sudo ./upgrade_debian.sh
```
