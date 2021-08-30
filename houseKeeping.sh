#!/bin/bash

# Original Author 
# https://gist.githubusercontent.com/imperialwicket/2727200/raw/83e05edf0d34a89ef729fc60346b531674606721/cleaner.sh

# Modified by TY

# Color Output for CMD

YELLOW=$'\e[1;33m' # Yellow Color.

RED=$'\e[0;31m' # Red Color.

GREEN=$'\e[0;32m' # Green Color.

CYA=$'\e[0;36m' # Light Blue Color.

PUR=$'\e[0;35m' # Purple Color.

BROWN=$'\e[0;33m' # Brown Color.

NC=$'\e[0m' # No Color.


# Basic Vars for Script and Logging.

TIMESTAMP=$(date +"%Y-%m-%d") # YYYYMMDD.

TIMESTAMP1=$(date +"%Y-%m") # YYYYMM.

BACKUP_BareOS=/home/ynutty/bareos/ # The Location where BareOS Puts the Backup Volumes at.

BACKUP_Local=/home/ynutty/bareos_Archive/ # The Location where You Would Like to Store the Old Backup Volumes.

RETENTION="+7" # Retention Period.

BACKUP_LOG=/home/ynutty/bareos_Logfile/${TIMESTAMP1}/${TIMESTAMP}_backup.log # The Location of Loggings.


# Logging Header

mkdir /home/ynutty/bareos_Logfile/${TIMESTAMP1}

echo "${PUR} \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ ${NC}" >> $BACKUP_LOG

echo "${CYA} ----- ----- ----- ${NC}" >> $BACKUP_LOG

echo "${CYA}Date: $(date)${NC}" >> $BACKUP_LOG

echo "${CYA}Hostname: $(hostname)${NC}" >> $BACKUP_LOG

echo "${CYA}Backup script has run. ${NC}" >> $BACKUP_LOG

echo "${CYA} ----- ----- ----- ${NC}" >> $BACKUP_LOG

# houseKeeping usage function -h

usage()

{

cat << EOF

houseKeeping.sh 
This script cleans directories.  It is useful for backup 
and log file directories, when you want to transport/delete older files. 
USAGE:  houseKeeping.sh [options]
OPTIONS:
   -h      Show this message
   -s      A search string to limit file deletion, defaults to '*' (All files).
   
EXAMPLES: 
   In the current directory, transport/delete everything but the 5 most recently touched 
   files: 
     houseKeeping.sh
         Same as:
     houseKeeping.sh -s *
   In the directory of bareos backup/house keeping folder, transport/delete all the files that match the vars including text "*"

EOF

}

# Set default values for VARS

SEARCH_STRING='keyword' # Default Search String.

MIN_FILES='0' # For while loop statement.

QUIET=0 # Useless VAR.

REMOVED=0 # For Counting File Transported Quantity.

DELETED=0 # For Counting FIle Deleted Quantity.

# houseKeeping transport files function.

transport()

{

FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING" 2>/dev/null | grep -vc "/$"` # For Couting the Total Number of Existed Files.

while [ $FILES_TRANSPORT -gt $MIN_FILES ]

do

  ls -tr *"$SEARCH_STRING" 2>/dev/null | head -1 | xargs -i mv {} $BACKUP_Local # Move New Volumes to the House Keeping Folder.

  FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING" 2>/dev/null | grep -vc "/$"` # While Loop, see line 94.

  let "REMOVED+=1" # Counting Feature.

done

}

# houseKeeping delete files function

delete()

{

FILES_DELETE=`find *"$SEARCH_STRING" -mtime "$RETENTION" 2>/dev/null | grep -vc "/$"` # For Couting the Total Number of Existed Files.

while [ $FILES_DELETE -gt $MIN_FILES ]

do

  find *$SEARCH_STRING -mtime $RETENTION 2>/dev/null | head -1 | xargs -i rm {} # Delete Old Volumes in the House Keeping Folder.

  FILES_DELETE=`find *"$SEARCH_STRING" -mtime "$RETENTION" 2>/dev/null | grep -vc "/$"` # While Loop, see line 94.

  let "DELETED+=1" # Counting Feature.

done

}

# Main Delete Function.

delete_volume()

{

    if [ $MIN_FILES = 0 ]

    then 

        echo "${RED}Delete the following files (y/n)?${NC}"

        echo "${RED}Delete the following files (y/n)?${NC}" >> $BACKUP_LOG

        find *$SEARCH_STRING -mtime $RETENTION 2>/dev/null -exec ls -l {} + >> $BACKUP_LOG 2>&1 # For Sending the "ll" Outputs to the Logging File.

    fi

    echo $CONFIRM_FILES_DELETE

    

    delete

    if [ $DELETED = 1 ]

    then

	    TEXT_DELETED='file.'    

    else

	    TEXT_DELETED='files.'

    fi

    echo " " >> $BACKUP_LOG

    echo Deleted $DELETED $TEXT_DELETED

    echo Deleted $DELETED $TEXT_DELETED >> $BACKUP_LOG

}

transport_volume()

{

    if [ $MIN_FILES = 0 ]

    then 

        echo "${RED}Transport the following files (y/n)?${NC}"

        echo "${RED}Transport the following files (y/n)?${NC}" >> $BACKUP_LOG

        ls -alF *"$SEARCH_STRING" >> $BACKUP_LOG 2>&1 # For Sending the "ll" Outputs to the Logging File.

    fi

    echo $CONFIRM_FILES_TRANSPORT

    

    transport

    if [ $REMOVED = 1 ]

    then

	    TEXT_TRANSPORTED='file.'

    else

	    TEXT_TRANSPORTED='files.'

    fi

    echo " " >> $BACKUP_LOG

    echo Transported $REMOVED $TEXT_TRANSPORTED

    echo Transported $REMOVED $TEXT_TRANSPORTED >> $BACKUP_LOG

}

# houseKeeping set args and handle help/unknown arguments with usage() function

while getopts  ":s:h" flag

do

  #echo "$flag" $OPTIND $OPTARG

  case "$flag" in

    h)

      usage

      exit 0

      ;;

    s)

      SEARCH_STRING=$OPTARG

      ;;

    ?)

      usage

      exit 1

  esac

done

# houseKeeping change to requested directory and perform delete with or without verbosity

cd $BACKUP_Local

CONFIRM_FILES_DELETE=`find *"$SEARCH_STRING" -mtime "$RETENTION" 2>/dev/null`

if [ $SEARCH_STRING = 'keyword' ]

then

    echo -e "${YELLOW}Usage:  houseKeeping.sh -s [Keyword]${NC}"

    echo -e "${YELLOW}Usage:  houseKeeping.sh -s [Keyword]${NC}" >> $BACKUP_LOG

    echo " " >> $BACKUP_LOG

    echo " " >> $BACKUP_LOG

    exit 0

fi

if [ ! -e *"$SEARCH_STRING" ]

then

    echo -e "${YELLOW}'$BACKUP_Local' is empty! Please Wait until House Keeping Volume Comes.${NC}"

    echo -e "${YELLOW}'$BACKUP_Local' is empty! Please Wait until House Keeping Volume Comes.${NC}" >> $BACKUP_LOG

    echo "${BROWN}################################################# ${NC}" >> $BACKUP_LOG

    # houseKeeping change to requested directory and perform transport with or without verbosity

    cd $BACKUP_BareOS

    CONFIRM_FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING"`

    if [ ! -e *"$SEARCH_STRING" ]

    then

        echo -e "${YELLOW}'$BACKUP_BareOS' is empty! Please Wait until the House Keeping Volume Comes.${NC}"

        echo -e "${YELLOW}'$BACKUP_BareOS' is empty! Please Wait until the House Keeping Volume Comes.${NC}" >> $BACKUP_LOG

        echo "${GREEN} ----- ----- Code being Executed End of Line ----- ----- ${NC}" >> $BACKUP_LOG

        echo " " >> $BACKUP_LOG

        echo " " >> $BACKUP_LOG

        exit 0

    fi

    echo "${GREEN} ----- ----- Code being Executed Start of Line ----- ----- ${NC}"

    echo "${GREEN} ----- ----- Code being Executed Start of Line ----- ----- ${NC}" >> $BACKUP_LOG

    transport_volume

else

    echo "${GREEN} ----- ----- Code being Executed Start of Line ----- ----- ${NC}"

    echo "${GREEN} ----- ----- Code being Executed Start of Line ----- ----- ${NC}" >> $BACKUP_LOG

    cd $BACKUP_Local

    checkRetention=`find *"$SEARCH_STRING" -mtime "$RETENTION" | wc -l`
    retentionResult=$checkRetention

    if [ $retentionResult -gt 0 ]
    then
        delete_volume
        echo "${BROWN}################################################# ${NC}" >> $BACKUP_LOG
    else
        echo "${YELLOW}No House Keeping Volumes in '$BACKUP_Local' Have Passed the $RETENTION Days Retention Period. ${NC}"
        echo "${YELLOW}No House Keeping Volumes in '$BACKUP_Local' Have Passed the $RETENTION Days Retention Period. ${NC}" >> $BACKUP_LOG
        echo "${BROWN}################################################# ${NC}" >> $BACKUP_LOG
    fi

    

    # houseKeeping change to requested directory and perform transport with or without verbosity

    cd $BACKUP_BareOS

    CONFIRM_FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING"`

    if [ ! -e *"$SEARCH_STRING" ]

    then

        echo -e "${YELLOW}'$BACKUP_BareOS' is empty! Please Wait until New Backup Volume Comes.${NC}"

        echo -e "${YELLOW}'$BACKUP_BareOS' is empty! Please Wait until New Backup Volume Comes.${NC}" >> $BACKUP_LOG

        echo "${GREEN} ----- ----- Code being Executed End of Line ----- ----- ${NC}" >> $BACKUP_LOG

        echo " " >> $BACKUP_LOG

        echo " " >> $BACKUP_LOG

        exit 0

    fi

    transport_volume

fi

# houseKeeping change back to the original directory

echo "${GREEN} ----- ----- Code being Executed End of Line ----- ----- ${NC}"

echo "${GREEN} ----- ----- Code being Executed End of Line ----- ----- ${NC}" >> $BACKUP_LOG

echo " " >> $BACKUP_LOG

echo " " >> $BACKUP_LOG

cd $OLDPWD

exit 0
