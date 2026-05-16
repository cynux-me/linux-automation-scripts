#!/bin/bash

count=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

#1_is_for_Scan_Folder
run_scan_folder() {

	echo "[$(date)] Scan Folder is Started." >> master_log.txt
	read -p "Which folder you want to scan? " target

	if [[ -d "$target" ]]; then
		echo "Scanning Star......"
		
		for f in "$target"/*; do
			
			if [[ -f "$f" ]]; then
			
				if [[ -r "$f" ]]; then
		
					if grep -q "eval" "$f" && grep -q "base64_decode" "$f" 2> /dev/null; then
					
						echo -e "${RED}Malware found in: $f ${NC}"
						chmod 000 "$f" 2> /dev/null
						security_f="scan_$(date +%d-%m-%Y).log"
						echo "[$(date)] Locked: $f" >> "$target/$security_f"
					
					else
						echo -e "${GREEN}No Malware found: $f ${NC}"
					fi
				fi
			fi
		done
		
		echo "Scan Complete. See details in Security_scan.log files."

		else
			echo "No such a directory found."
		fi
}

#2_is_for_fil_organization
run_file_organizer(){

	echo "[$(date)] File Organization is Started." >> master_log.txt
	read -p "Which folder you want to organize? " target

	if [[ -d "$target" ]]; then

		mkdir -p "$target/Images" "$target/Documents" "$target/Others" 2> /dev/null

		for f in "$target"/*; do

			if [[ -f "$f" ]]; then

				if [[ "$f" == *.jpg || "$f" == *.png || "$f" == *.gif ]]; then
					mv "$f" "$target/Images/"

				elif [[ "$f" == *.pdf || "$f" == *.docs || "$f" == *.txt ]]; then
					mv "$f" "$target/Documents/"
				else
					if [[ "$f" != "$0" ]]; then
						mv "$f" "$target/Others/"
					fi
				
				fi
			
			fi
		
		done
		
		echo "Organizing all files is complete."

		else
			echo "No such a directory is found."
		
		fi

}

#4 is for System Cleanup
run_system_cleanup() {

	echo "[$(date)] System Cleanup is Started." >> master_log.txt

	read -p "Which folder you want to clean: " target

	if [[ -d "$target" ]]; then

		echo "Searching for old logs (>100MB and >30 Days old)....."

		files=$(find "$target" -type f -name "*.log" -size +100M -mtime +30 2> /dev/null)

		if [[ -z "$files" ]]; then

			echo "No old large log files found."

		else

			echo "The following files are found: "
			echo "$files"
			echo "-------------------------------"
			read -p "Do you want to delete these files (yes/no): " confirm

			if [[ "${confirm,,}" == "yes" ]]; then

				find "$target" -type f -name "*.log" -size +100M -mtime +30 -delete 2> /dev/null
				echo "Cleanup Complete. Files deleted."

			else
				echo "Cleanup Cancelled." 

			fi

		fi

	else

		echo "Error! No Directory found."

	fi

}

#5 is for Backup and Transfer
run_backup_transfer() {

	echo "[$(date)] Backup and Transfer is Started." >> master_log
	read -p "Which folder you want to backup? " target

	if [[ -d "$target" ]]; then

		backup_file="backup_$(date +%d-%m-%Y).tar.gz"
		echo "Creating a compressed backup...."

		tar -czf "$backup_file" "$target" 2> /dev/null

		echo "Backup Created: $backup_file"

		echo "___________________________________"

		read -p "Do you want to send this backup to a remote server (yes/no)? " confirm

		if [[ "${confirm,,}" == "yes" ]]; then

			read -p "Enter Remote Server Username: " r_user
			read -p "Enter Remote Server IP: " r_ip 
			read -p "Enter Remote Destination Path: " r_path

			echo "Transfaring backup to $r_ip...."
			scp "$backup_file" "$r_user@$r_ip:$r_path"

			if [[ $? -eq 0 ]]; then

				echo "Transfer Successfully."

			else
				echo "Transfer failed. Please check IP/Credentials."
			fi
		else
			echo "Backup Saved Locally at $(pwd)/$backup_file"
		fi

	else
		echo "Error! Directory not found."
	fi
}


#3 is for Check Server Health
run_server_health() {

	echo "[$(date)] Checking Server Health is Started." >> master_log.txt
	echo "--- Server Health Status ---"
	echo "Current User: $(whoami)"
	echo "System Uptime: $(uptime -p)"
	echo "Disk Usage: "
	df -h  | grep '^/dev/'
	echo "----------------------------"
}

run_search_file() {

	echo "[$(date)] File Searching Started." >> master_log.txt
	read -p "Which file you want to search: " file_n

	if [[ -z "$file_n" ]]; then
		echo "Error: You didn't enter a filename!"
	else
		echo "Searching for '$file_n'..."
		result=$(find . -name "$file_n" 2> /dev/null)

		if [[ -z "$result" ]]; then
			echo "No file found with that name."
		else
			echo "File(s) found at: "
			echo "$result"
		fi
	fi
}

#8 is for System Resource Report
run_resource_monitor() {

	echo "[$(date)] System Resource Report Started." >> master_log.txt

	echo "================================"
	echo "     System Resource Report     "
	echo "================================"

	echo "Memory Usage: "
	free -h
	echo " "

	echo "Top 5 CPU Consuming Processes: "
	ps -eo pcpu,pmem,args --sort=-pcpu | head -n 6

	echo "=================================="


}

while true; do
	echo ""
	echo "========================================="
	echo "      MONIR's Security Toolkit (V1)      "
	echo "========================================="
	echo "1. Malware Sacn (Scan)"
	echo "2. File Organizer (Organize)"
	echo "3. Server Health"
	echo "4. System Cleanup"
	echo "5. Backup and Transfer"
	echo "7. Searching File"
	echo "8. System Resource Report"
	echo "6. Exit"
	echo "========================================="
	read -p "Press or Choose your option (1/2/3/4/5/6): " choice

	echo "[$(date) User: $USER selected option: $choice." >> master_log.txt

case $choice in
	1)
		run_scan_folder
		;;

	2)
		run_file_organizer
		;;

	3)
		run_server_health
		;;

	4)
		run_system_cleanup
		;;

	5)
		run_backup_transfer
		;;

	6)
		echo "Bye! Happy Day."
		exit 0
		;;

	7)
		run_search_file
		;;

	8)
		run_resource_monitor
		;;


	*)
		((count++))
		echo "[$(date)] $USER wrong input $count times. Choice was: $choice" >> master_log.txt
		echo "Wrong Entry! Please Press 1, 2, or 3"
		sleep 2
		clear
		;;
	esac
done
