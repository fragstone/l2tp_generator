#!/bin/bash

# Dieses Proramm dient zu Einrichtung eines FullMesh auf Layer2 mit hilfe von LACPv3
# Unterstuetzt werden dabei bis zu 9 Nodes und maximal 9 Batman Instanzen
# Erstellt von Thomas Fragstein

# Variablen:

#Name der Subdomain
DOMAIN='Niersufer'
#Name der BATMAN Instanzen
DOMAINNAME=('beispiel1' 'beispiel2')
# Nodebezeichnungen
NODENAME=('map' 'node01' 'node02' )
# IP der Nodes (Anzahl muss mit der Arrayvariablen in $NODENAME übereinstimmen)
NODEIP=('1.2.1.1' '1.1.2.1' '1.1.1.2' )

# Programmstart

if [[ ${#NODEIP[*]} != ${#NODENAME[*]} ]]
then
echo "Anzahl von NODEIP und NODENAME stimmen nicht ueberein"
exit 1
fi

echo "  L2TPv3 Konfiguration für das Niersufer `date +%F`"
echo "========================================================================================================================================"

for NODE in `seq 1 ${#NODEIP[*]}`
do
echo "  Konfiguration fuer ${NODENAME[$(($NODE-1))]}"
echo "========================================================================================================================================"
  for RNODE in `seq 1 ${#NODEIP[*]}`
  do
    # Tunnel auf sich selbst macht keinen sinn
    [ "$NODE" -eq "$RNODE" ] && continue

    # L2TPv3 Tunnel einrichten
    echo "ip l2tp add tunnel tunnel_id ${NODE}1${RNODE} peer_tunnel_id ${RNODE}1${NODE} udp_sport 1${NODE}11${RNODE} udp_dport 1${RNODE}11${NODE} encap udp local ${NODEIP[$(($NODE-1))]} remote ${NODEIP[$(($RNODE-1))]}"

    for DOMAINID2 in `seq ${#DOMAINNAME[*]}`
    do

      # Sessions innerhalb des L2TPv3 Tunnels einrichten
      echo "ip l2tp add session name bb${DOMAINNAME[$(($DOMAINID2-1))]}-${NODENAME[$((${RNODE}-1))]} tunnel_id ${NODE}1${RNODE} session_id ${NODE}${DOMAINID2}${RNODE} peer_session_id ${RNODE}${DOMAINID2}${NODE}"
      # HINWEIS: Bei Debian 7 bitte die folgende Zeile auskomentieren da der Kernel diese open noch nicht unterstützt.
      echo "ip link set bb${DOMAINNAME[$(($DOMAINID2-1))]}-${NODENAME[$((${RNODE}-1))]} address 00:16:3e:b${NODE}:b${DOMAINID2}:b${RNODE}"
      echo "ip link set bb${DOMAINNAME[$(($DOMAINID2-1))]}-${NODENAME[$((${RNODE}-1))]} up mtu 1488"
      echo "batctl -m bat0-${DOMAINNAME[$(($DOMAINID2-1))]} if add bb${DOMAINNAME[$(($DOMAINID2-1))]}-${NODENAME[$((${RNODE}-1))]}"
      echo
    done
  done
  echo "========================================================================================================================================"
  echo "  Konfiguration Ende fuer ${NODENAME[$(($NODE-1))]}"
  echo "========================================================================================================================================"
done

