#!/bin/bash
if [ -d "/etc/squid/" ]; then
    payload="/etc/squid/payload.txt"
elif [ -d "/etc/squid3/" ]; then
	payload="/etc/squid3/payload.txt"
fi
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%35s%s%-10s\n' "เพิ่มโฮสต์ไปที่ Squid Proxy" ; tput sgr0
if [ ! -f "$payload" ]
then
	tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo "ไฟล์ $payload ไม่พบ" ; tput sgr0
	exit 1
else
	tput setaf 2 ; tput bold ; echo ""; echo "โดเมนปัจจุบันในไฟล์ $payload:" ; tput sgr0
	tput setaf 3 ; tput bold ; echo "" ; cat $payload ; echo "" ; tput sgr0
	read -p "ป้อนโดเมนที่คุณต้องการเพิ่มในรายการ: " host
	if [[ -z $host ]]
	then
		tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo "คุณป้อนโดเมนว่างหรือไม่มีอยู่!" ; echo "" ; tput sgr0
		exit 1
	else
		if [[ `grep -c "^$host" $payload` -eq 1 ]]
		then
			tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo "โดเมน $host มีอยู่แล้วในไฟล์ $payload" ; echo "" ; tput sgr0
			exit 1
		else
			if [[ $host != \.* ]]
			then
				tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo "คุณต้องเพิ่มโดเมนที่ขึ้นต้นด้วยจุด!" ; echo "Por exemplo: .phreaker56.xyz" ; echo "ไม่จำเป็นต้องเพิ่มโดเมนย่อยสำหรับโดเมนที่มีอยู่แล้วในไฟล์" ; echo "นั่นคือไม่จำเป็นต้องเพิ่มการชาร์จ.claro.com.br" ; echo "ถ้าโดเมน .claro.com.br อยู่ในไฟล์แล้ว." ; echo ""; tput sgr0
				exit 1
			else
				echo "$host" >> $payload && grep -v "^$" $payload > /tmp/a && mv /tmp/a $payload
				tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "Arquivo $payload อัปเดต, เพิ่มโดเมนเรียบร้อยแล้ว:" ; tput sgr0
				tput setaf 3 ; tput bold ; echo "" ; cat $payload ; echo "" ; tput sgr0
				if [ ! -f "/etc/init.d/squid3" ]
				then
					service squid3 reload
				elif [ ! -f "/etc/init.d/squid" ]
				then
					service squid reload
				fi	
				tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "โหลด Squid Proxy สำเร็จแล้ว!" ; echo "" ; tput sgr0
				exit 1
			fi
		fi
	fi
fi
