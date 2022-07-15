echo -e "RHS"
echo
echo "RHS"
echo
echo -e "033[97mPackets/s \033[36m{}\n\033[97mBytes/s \033[36m{}\n\033[97mKbp/s \033[36m{}\n\033[97mGbp/s \033[36m{}\n\033[97mMbp/s \033[36m{}"
interface=eth0
dumpdir=/root/dumps
url='' ## Change this to your Webhook URL
while /bin/true; do
  old_b=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $1 }'`
  
  old_ps=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $2 }'`
  sleep 1
  new_b=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $1 }'`

  new_ps=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $2 }'`
  ##Defining Packets/s
  pps=$(( $new_ps - $old_ps ))
  ##Defining Bytes/s
  byte=$(( $new_b - $old_b ))


  echo -ne "\r$pps packets/s\033[0K"
  tcpdump -n -s0 -c 800 -w $dumpdir/capture.`date +"%Y%m%d-%H%M%S"`.pcap
  echo "`date` Detecting Attack Packets."
  sleep 1
  if [ $pps -gt 2000 ]; then ## Attack alert will display after incoming traffic reach 30000 PPS
    echo " Attack Detected Monitoring Incoming Traffic"
    curl -H "Content-Type: application/json" -X POST -d '{
      "embeds": [{
      	"inline": false,
        "title": "Attack Detected On",
        "username": "Attack Alerts",
        "color": 15158332,
         "thumbnail": {
          "url": "https://media.discordapp.net/attachments/972675304013307905/990835322965352489/unknown.png"
        },
         "footer": {
            "text": "Our system is attempting to mitigate the attack and automatic packet dumping has been activated.",
            "icon_url": "https://rhscloud.net/templates/RHSCloud/img/RHSSiteLogoWhite.png"
          },
    
        "description": "Detection of an attack",
         "fields": [
      {
        "name": "**Server Provider**",
        "value": "serverguard.cloud",
        "inline": false
      },
            {
        "name": "**Incoming Packets**",
        "value": " '$pps' Pps ",
        "inline": false
      },
       {
        "name": "**check-host**",
        "value": "https://check-host.net",
        "inline": false
      },
      {
        "name": "**Servers IP Address**",
        "value": "154.12.232.30",
        "inline": false
      }
    ]
      }]
    }' $url
    echo "Paused for."
    sleep 10  && pkill -HUP -f /usr/sbin/tcpdump  ## The "Attack no longer detected" alert will display in 220 seconds
    ## echo "Traffic Attack Packets Scrubbed"
    echo -ne "\r$mbps megabytes/s\033[97"
    curl -H "Content-Type: application/json" -X POST -d '{
      "embeds": [{
      	"inline": false,
        "title": "Attack Stopped",
        "username": "  Attack Alerts",
        "color": 3066993,
         "thumbnail": {
          "url": "https://media.discordapp.net/attachments/972675304013307905/990835125749170217/unknown.png"
        },
         "footer": {
            "text": "Our system has mitigated the attack and automatic packet dumping has been deactivated.",
            "icon_url": "https://rhscloud.net/templates/RHSCloud/img/RHSSiteLogoWhite.png"
          },    
          
        "description": "End of attack",
         "fields": [
      {
        "name": "**Server Provider**",
        "value": "serverguard.cloud",
        "inline": false
      },
            {
        "name": "**Packets**",
        "value": "'$pps' pps ",
        "inline": false
      },
     {
        "name": "**check-host**",
        "value": "https://check-host.net",
        "inline": false
      },
      {
        "name": "**Servers IP Address**",
        "value": "154.12.232.30",
        "inline": false
      }
    ]
      }]
    }' $url
  fi
done
