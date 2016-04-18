#!/bin/bash 

if [ "$EUID" -ne 0 ]
  then echo "This script must be run with super-user privileges."
  exit
fi

function load_config {
  if [ -a "./ibeacon.conf" ]
  then
    . ./ibeacon.conf
  else
    echo "Configuration file ./ibeacon.conf not found"
    exit 1
  fi
}

function start_beacon {
  load_config
  echo "Launching virtual iBeacon..."
  hciconfig $BLUETOOTH_DEVICE down
  hciconfig $BLUETOOTH_DEVICE up
  hciconfig $BLUETOOTH_DEVICE noleadv
  hciconfig $BLUETOOTH_DEVICE noscan
  hciconfig $BLUETOOTH_DEVICE leadv 3
#  hcitool -i hci0 cmd 0x08 0x0008 1e 02 01 1a 1a ff 4c 00 02 15 $UUID $MAJOR $MINOR $POWER 00 00 00 00 00 00 00 00 00 00 00 00 00
  hcitool -i hci0 cmd 0x08 0x0008 1e 02 01 1a 1a ff 4c 00 02 15 $UUID $MAJOR $MINOR $POWER
  echo "Complete"  
  echo ""
  echo "UUID: $UUID"
  echo "VERSION: $MAJOR.$MINOR"
  echo "POWER: $POWER"
}

function stop_beacon {
  load_config
  echo "Disabling virtual iBeacon..."
  hciconfig $BLUETOOTH_DEVICE noleadv
  echo "Complete"
}

function print_usage {
  echo "This script must be run with super-user privileges." 
  echo -e "\nUsage:\n$0 [--start|--stop] \n" 
}

# Generate a pseudo UUID
function print_uuid {
    local N B T

    for (( N=0; N < 16; ++N ))
    do
        B=$(( $RANDOM%255 ))

        if (( N == 6 ))
        then
            printf '4%x' $(( B%15 ))
        elif (( N == 8 ))
        then
            local C='89ab'
            printf '%c%x' ${C:$(( $RANDOM%${#C} )):1} $(( B%15 ))
        else
            printf '%02x' $B
        fi

	if [ T%2==0 ]
	then
		printf ' '
	fi
    done
    echo
}

key="$1"
case $key in
  -r|--restart|--start)
    start_beacon
    ;;
  -s|--stop)
    stop_beacon
    ;;
  -u|--uuid)
    print_uuid
    ;;
  *)
    print_usage
    ;;
esac

exit 0
