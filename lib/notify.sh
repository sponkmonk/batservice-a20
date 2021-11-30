#!/system/bin/sh
termux-notification -h > /dev/null 2>&1
e=$?

if [ $e -ne 0 ]; then
  notify_status () { :; }
  notify_quit() { :; }
else
  notify_txt () {
    if ( [ "$status" = "Not charging" ] || [ "$status" = "Charging" ] ); then
      p=" (🔌 $current)"
    else
      p=""
    fi
    statustxt="🔋 $percent %$p ⚡ $voltage V 🌡 $temp °C"
  }

  notify_status () {
    notify_txt
    termux-notification -i batservice -t "Serviço da Bateria" -c "$statustxt" --ongoing
  }
  notify_quit () {
    termux-notification-remove batservice
    exit 0
  }
fi

while [ 0 ]; do
  read log_line || notify_quit
  _status=$(echo "$log_line" | grep -Eo '[A-Z][a-z]+( [a-z]+)*ging')
  if [ $? -eq 0 ]; then status=$_status; fi
  _percent=$(echo "$log_line" | grep " %" | grep -Eo '[0-9]+')
  if [ $? -eq 0 ]; then percent=$_percent; fi
  _current=$(echo "$log_line" | grep " mA" | grep -Eo '[+\-]{0,1}[0-9]+')
  if [ $? -eq 0 ]; then current=$_current; fi
  _voltage=$(echo "$log_line" | grep " mV" | grep -Eo '[0-9]+')
  if [ $? -eq 0 ]; then voltage=$_voltage; fi
  _temp=$(echo "$log_line" | grep " .C" | grep -Eo '[0-9]+')
  if [ $? -eq 0 ]; then
    temp=$_temp
    notify_status
  fi
done
