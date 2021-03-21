#!/bin/bash
srchdhost=($1)
variable=()
sayi=1
test='^[a-z][a-z0-9]-'
HEIGHT=0
WIDTH=0
CHOICE_HEIGHT=20
BACKTITLE="SSH CONNECTION TOOL"
TITLE="CONNECT SSH"
MENU="SELECT SERVER TO CONNECT"


if [[ -z $srchdhost ]] ; then
srchdhost="^[a-z][a-z]"
fi

# Add to variable list servername and ip address lines in securecrt.xml and select lines with  "xx -" pattern and matched letters given in $1
for i in `cat /opt/hosts/securecrt.xml | grep -iP "<key name=" | awk -F'=' '{print $2}'|cut -d "=" -f 1|cut -d "\"" -f 2| grep "$srchdhost"`
do 
if [[ $i =~ $test ]]; then
variable+=("$i")
fi
done

OPTIONS=()
  for i in "${variable[@]}"
    do
      y=${i//-/         -      }
      OPTIONS+=("$sayi" "$i")
      sayi=$((sayi+1))
    done

CHOICE_HEIGHT=$((sayi-1))

if [[ $CHOICE_HEIGHT -eq 0 ]]; then
  echo "No records for searched pattern"
  exit
fi

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

if [[ $? -eq 1 ]];then
  clear
  exit
fi

clear

if [[ $CHOICE =~ [0-9] ]]; then
  baglan=$((CHOICE-1))
  ipaddres=${variable[$baglan]}
  ipadr="${ipaddres##*[^0-9.0-9.0-9.0-9]}"
  if [[ $ipadr =~ ^[0-9] ]]; then
    ssh $ipadr
  else 
    echo Ip address not found
    exit 1
  fi
else
  exit 1
fi
