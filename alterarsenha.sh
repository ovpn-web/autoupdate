#!/bin/bash
tput setaf 7 ; tput setab 4 ; tput bold ; printf '%35s%s%-10s\n' "Alterar Senha de Usuário" ; tput sgr0
echo ""
echo -e "\033[1;33mรายชื่อผู้ใช้และรหัสผ่านของพวกเขา: \033[0m"
echo""
_userT=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody)
i=0
unset _userPass
while read _user; do
	i=$(expr $i + 1)
	_oP=$i
	[[ $i == [1-9] ]] && i=0$i && oP+=" 0$i"
	if [[ -e "/etc/SSHPlus/senha/$_user" ]]; then
		_senha="$(cat /etc/SSHPlus/senha/$_user)"
	else
		_senha='Null'
	fi
	suser=$(echo -e "\033[1;31m[\033[1;36m$i\033[1;31m] \033[1;37m- \033[1;32m$_user\033[0m")
    ssenha=$(echo -e "\033[1;33mSenha\033[1;37m: $_senha")
    printf '%-60s%s\n' "$suser" "$ssenha"
	_userPass+="\n${_oP}:${_user}"
done <<< "${_userT}"
num_user=$(awk -F: '$3>=1000 {print $1}' /etc/passwd | grep -v nobody | wc -l)
echo ""
echo -ne "\033[1;32mพิมพ์หรือเลือกผู้ใช้ \033[1;33m[\033[1;36m1\033[1;31m-\033[1;36m$num_user\033[1;33m]\033[1;37m: " ; read option
user=$(echo -e "${_userPass}" | grep -E "\b$option\b" | cut -d: -f2)
if [[ -z $option ]]
then
	tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "ช่องว่างหรือไม่ถูกต้อง!" ; echo "" ; tput sgr0
	exit 1
elif [[ -z $user ]]
then
	tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "คุณป้อนชื่อว่างหรือไม่ถูกต้อง!" ; echo "" ; tput sgr0
	exit 1
else
	if [[ `grep -c /$user: /etc/passwd` -ne 0 ]]
	then
		echo -ne "\n\033[1;32mรหัสผ่านใหม่สำหรับผู้ใช้ \033[1;33m$user\033[1;37m: "; read password
		sizepass=$(echo ${#password})
		if [[ $sizepass -lt 4 ]]
		then
			tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "รหัสผ่านว่างเปล่าหรือไม่ถูกต้อง! ใช้อย่างน้อย 4 ตัวอักษร" ; echo "" ; tput sgr0
			exit 1
		else
			ps x | grep $user | grep -v grep | grep -v pt > /tmp/rem
			if [[ `grep -c $user /tmp/rem` -eq 0 ]]
			then
				echo "$user:$password" | chpasswd
				tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "รหัสผ่านผู้ใช้ $user ถูกเปลี่ยนเป็น: $password" ; echo "" ; tput sgr0
				echo "$password" > /etc/SSHPlus/senha/$user
				exit 1
			else
				echo ""
				tput setaf 7 ; tput setab 4 ; tput bold ; echo "ผู้ใช้เข้าสู่ระบบ ตัดการเชื่อมต่อ..." ; tput sgr0
				pkill -f $user
				echo "$user:$password" | chpasswd
				tput setaf 7 ; tput setab 1 ; tput bold ; echo "" ; echo "รหัสผ่านสำหรับผู้ใช้  $user ผู้ใช้ถูกเปลี่ยนเป็น: $password" ; echo "" ; tput sgr0
				echo "$password" > /etc/SSHPlus/senha/$user
				exit 1
			fi
		fi
	else
		tput setaf 7 ; tput setab 4 ; tput bold ; echo "" ; echo "ผู้ใช้ $user ไม่มีอยู่!" ; echo "" ; tput sgr0
	fi
fi
