#!/bin/bash
#******************************************************
# Auther : Seyed Ali Miramirkhani | StID : 953618043010
# Date : 1397/03/10
# Bash script to manage the user
# This script will help to create/delete/check the user
#******************************************************

#***************     FUNCTION DECLARATION     *************

#---> Function to create the user
createUser ()
{
#---> This loope will create an random ID and check it if it is duplicate 
while true ; do
	theRandomID=$(shuf -i 1000-9999 -n 1)	##generate random ID
	awk -F ":" '{print $3}' /etc/passwd | grep "$theRandomID" > /dev/null ##check for duplicate
	if [ $? -ne 0 ] ; then
	 break ##ID is valid
	fi
done
#--->procedure to create an user
mkdir /home/"$1" ##make home directory for the user
echo "$1:x:$theRandomID:$theRandomID:$2$3:/home/$1:/bin/bash" >> /etc/passwd ##put an entry in passwd file
echo "$1:x:$theRandomID:" >> /etc/group ##put an entry in group file
cp -r /etc/skel/* /home/"$1"/ ##fill the home directory with basic files
chown -R "$1":"$1" /home/"$1" ##give the user own access to his/her home directory
passwd "$1" ##put an entry in shadow file and set pasword for the user
echo "UserID $1 with UID $theRandomID and GID $theRandomID created for $2 $3 @ $(date)"
echo "UserID $1 with UID $theRandomID and GID $theRandomID created for $2 $3 @ $(date)" >> /var/log/usermanagement.log
}

#**************  MAIN COMMAND PROCESSOR    *****************

#--->recognize create command
if [ "$1" = "--create" ] || [ "$1" = "-c" ] ; then
	if [ "$2" = "-f" ] ; then ##check for the first name
		if [ -z "$3" ] ; then ##check if First name is empty
			echo "you didn't set first name" 
		else
			if [ "$4" = "-l" ] ; then ##check for the last name
				if [ -z "$5" ] ; then ##check if Last name is empty
					echo "you didn't set the last name"
				else
					fname=$3
					lname=$5
					grep "$3$5" /etc/passwd > /dev/null ##check if the user is duplicate
					if [ $? -ne 0 ] ; then
						compName=$(echo $fname | head -c 1)\.$lname ##create texture username
						grep "^$compName" /etc/passwd > /dev/null	##check if texture user name is duplicate
						if [ $? -eq 0 ] ; then
							compName=$(echo $fname | cut -c 2)\.$lname ##ckek if the new testure user name is duplicate 
							grep "^$compName" /etc/passwd > /dev/null ##abort the command becuaseof exture username failure
							if [ $? -eq 0 ] ; then
								echo "the name is already exist"
							else
								createUser "$compName" "$3" "$5" ##pass the argument to the dunction to create the user
							fi
						else
							createUser "$compName" "$3" "$5" ##pass the argument to the dunction to create the us
						fi
					else
						echo "user already exist"
					fi
				fi
			else
			echo "the format is incorrct"
			fi	
		fi
	else
		echo "not a correct format"
	fi
	
#--->recognize delete command
elif [ "$1" = "--delete" ] || [ "$1" = "-d" ] ; then 
	if [ "$2" = "-u" ] ; then ##check for the correct switch
		if [ -z "$3" ] ; then ##check if the userName field is empty
			echo "you didn't enter the userName to delete"
		else
			gsrep "^$3" /etc/passwd > /dev/null ##check if the entered user exist in the database
			if [ $? -eq 0 ] ; then
#----------------------------IMPORTANT--------------------------------------
				theID=$(id -u $3) ##save some attribute for futhur useage
				textID=$3
#these two commands will take a lot of time to execute if you sure about it  you can uncommnet them
			#	find / -user $(id -u $3) -exec rm -rf {} \; 2>/dev/null ##delete whatever blongs to the user
			#	find / -group $(id -u $3) -exec rm -fr {} \; 2>/dev/null ##delte whatever blongs to the user group
				rm -rf /home/"$3"/ ##delete all the data of the user in his\her home directory
				rm -rf /var/mail/"$3"/ ##delete user email box
				sed -i "/^$3/d" /etc/passwd ##delete user entry from passwd file
				sed -i "/^$3/d" /etc/shadow ##delete user entry from shadow file
				sed -i "/^$3/d" /etc/group ##delte user entry from group file
				echo "UserID $textID with UID $theID removed @ $(date)"
				echo "UserID $textID with UID $theID removed @ $(date)" >> /var/log/usermanagement.log
			else
			echo "the userName you entered does not exist in the database"
			fi
		fi
	else
		echo "wrong format of deletion"
	fi
	
#--->recognize check command
elif [ "$1" = "--check" ] || [ "$1" = "-i" ] ; then
	if [ "$2" = "-u" ] ; then ##check if swtich is entered correctly
		if [ -z "$3" ] ; then ##check if the userName is empty
			echo "you didn't enter the userName to delete"
		else
			grep "^$3" /etc/passwd > /dev/null ##check if the user exist in the database
			if [ $? -eq 0 ] ; then
				echo "the user information is: \n $(id $3)" ##return the required information of the user
				echo "UserID $3 with UID $(id -u $3) has been checked @ $(date)" >> /var/log/usermanagement.log
			else
				echo "the userName you entered does not exsit"
			fi
		fi
	else
		echo "wrong format of user checking"
	fi
else
echo "command is not recognized"
fi

