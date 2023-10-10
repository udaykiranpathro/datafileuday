Cleanup script for github enterprise servers

#!/bin/bash

# Set the path to your repository
REPO_PATH=/elp/dev/repo

# Set the number of days of files to keep
DAYS_TO_KEEP=60

# Go to the repository directory
cd $REPO_PATH

# Remove files that are older than $DAYS_TO_KEEP
find . -type f  -mtime +$DAYS_TO_KEEP  -delete

# Remove empty directories
find . -type d -empty -delete

echo " the empty files and directories are remove"

This script will find and remove all files in your repository that are older than the 
specified number of days to keep. It will also remove any empty directories.



========================================================================


Script to clear maven local repository disk space

sunday every week at 12.03 am 
#!/bin/bash
df -kh 
echo "====="
cd /dockershare/.m2/repository
echo "====="
echo $PWD
echo "====="
find . -name "PR-*"| xargs rm -rf

df_before=`df -h  | grep "/dockershare" | awk '{print $4}'`
echo " Available space before cleanup "$df_before" " 

cd /dockershare/.m2/repository/com/cscinfo
echo $PWD
echo "====="
find . -mtime +60 -iname "*SNAPSHOT"| xargs rm -rf
find . -name '*.war' -type f -mtime +60 | xargs rm -rf
df_after=`df -h  | grep "/dockershare" | awk '{print $4}'`
echo " Available space after cleanup "$df_after" " 


=====================================================================



1.Clean-up script for Jenkins

#!/bin/bash
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
df -h 
df_before=`df -h  | grep "/var" | awk '{print $4}'| sed "s/%//"` 
CAPACITY=85
TIME=180
CLEANUP_DIR=/var/lib/jenkins/jobs/
if [ $(df -h  | grep "/var" | awk '{print $4}'| sed "s/%//") -gt $CAPACITY ]
then
    find /var/lib/jenkins/jobs -name '*.war' -type f -mtime +90 |  xargs rm -rf 
	find "$CLEANUP_DIR" -name '*.jar' -type f -mtime +"$TIME" | xargs rm -rf
fi 
df_after=`df -h  | grep "/var" | awk '{print $4}'| sed "s/%//"`(file system availbale space after the activity)
echo " Available space before cleanup "$df_before" "
echo " Available space after cleanup "$df_after" "
echo " Please check this `$REMOVED_FLS_DIR` directory for deleted files list. "
change the global config. to qlgithub
ask uers to run the jobs and get update

==========================================================

3.Script to disable self timer jobs in jenkins

1st approach
#!/bin/bash

# Get a list of all jobs in Jenkins
jobs=$(curl -s "http://jenkins_url/api/json?tree=jobs[name,url]")

# Loop through each job and check if it has a self-timer trigger
for job in $(echo $jobs | jq -r '.jobs[].name'); do
    triggers=$(curl -s "http://jenkins_url/job/$job/config.xml" | grep -o "hudson.triggers.TimerTrigger")
    if [ -n "$triggers" ]; then
        # Disable the self-timer trigger for the job
        curl -X POST -H "Content-Type: text/xml" --data "<project><disabled>true</disabled></project>" "http://jenkins_url/job/$job/disable"
    fi
done


=======================================================================


4.script to download java package into jenkins from artifactory

#!/bin/bash -ue
version=8.33.0.1
jdkUrl=https://artifactory2.example.com/artifactory/zulu-jdk/zulu8.33.0.1-ca-jdk8.0.192-linux_x64.tar.gz
jdkArchive=$(basename $jdkUrl)
jdkName="${jdkArchive%.tar.gz}"
jdkDir="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
thisJdkDir=${jdkDir}/${jdkName}

if ! type wget >/dev/null 2>&1; then
    echo "ERROR: Unable to run wget"
    exit 1
fi

if [ -x $thisJdkDir/bin/java ]; then
    JAVA_HOME="$thisJdkDir"
    if $JAVA_HOME/bin/java -version 2>&1 | grep -q "$version"; then
        exit 0
    fi
fi

echo "Installing Zulu ${version} in ${thisJdkDir}"
rm -rf $thisJdkDir
wget --no-verbose --referer=http://www.azulsystems.com/products/zulu/downloads $jdkUrl -O ${jdkArchive}
tar -xf ${jdkArchive}
rm -f ${jdkArchive}
echo "Zulu ${version} installed in ${thisJdkDir}"
exit 0



==================================================================================================


Shell script to remove all unused and dangling images 

#!bin/bash
# Remove all the dangling images
DANGLING_IMAGES=$(docker images -qf "dangling=true")
if [[ -n $DANGLING_IMAGES ]]; then
    docker rmi "$DANGLING_IMAGES"
fi
# Get all the images currently in use
USED_IMAGES=($( \
    docker ps -a --format '{{.Image}}' | \
    sort -u | \
    uniq | \
    awk -F ':' '$2{print $1":"$2}!$2{print $1":latest"}' \
))

# Get all the images currently available
ALL_IMAGES=($( \
    docker images --format '{{.Repository}}:{{.Tag}}' | \
    sort -u \
))

# Remove the unused images
for i in "${ALL_IMAGES[@]}"; do
    UNUSED=true
    for j in "${USED_IMAGES[@]}"; do
        if [[ "$i" == "$j" ]]; then
            UNUSED=false
        fi
    done
    if [[ "$UNUSED" == true ]]; then
        echo "$i"
        docker rmi "$i"
       
    fi
done

#The below command works for the Higher version of Docker
#docker image prune -a --force --filter "until=720h"
=============================================================================================================================================================

test.sh

#!/usr/bin/env bash

# Script Name: recently_modified_files.sh
# Description: This script lists the most recently modified files in a given directory.
# Usage: `recently_modified_files.sh [dir] [n]`
# Example: `recently_modified_files.sh /home/user/documents 5` lists the 5 most recently modified files in the directory `/home/user/documents`

dir="$1"
n="$2"

# Set default values for dir and n if no arguments are provided
if [ -z "$dir" ]; then
    dir="."
fi

if [ -z "$n" ]; then
    n=10
fi

find "$dir" -type f -printf '%TY-%Tm-%Td %TT %p\n' | sort -r | head -n "$n" 


==================================================================================


#!/bin/bash

# Define backup directory and filename
BACKUP_DIR="/backup"
TIMESTAMP=$(date +'%Y%m%d%H%')
BACKUP_FILENAME="mavan_backup_$TIMESTAMP.tar.gz"

# Source directory to be backed up
SOURCE_DIR="/vmave/repo/.m2"

# Create the backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Use tar to create a compressed backup of the Jenkins directory
tar -czvf "$BACKUP_DIR/$BACKUP_FILENAME" "$SOURCE_DIR"

# Check if the backup was successful
if [ $? -eq 0 ]; then
  echo "Backup of Jenkins directory completed successfully."
  echo "Backup saved as: $BACKUP_DIR/$BACKUP_FILENAME"
else
  echo "Backup of Jenkins directory failed!"
fi




[ $? -eq 0 ]: Inside the square brackets [ ], we have a conditional expression that checks whether the exit status of the previous command (represented by $?) is equal to 0.

$?: In Bash, $? is a special variable that holds the exit status of the last executed command. An exit status of 0 typically indicates success, while a non-zero exit status indicates an error or failure.

-eq: This is a comparison operator used to check if two values are equal. In this case, we're checking if the exit status is equal to 0.



===========================================================

#!/bin/bash
TIMESTAMP=$(date +'%Y%m%d%H%')
# Use the ps command to list all processes, sort them by CPU usage, and display the top 5
top_processes=$(ps -ef --sort=-%cpu | head -n 6)

# Print a header
echo "Top 5 Processes by CPU Usage:"
echo "--------------------------------"

# Print the top processes
echo "$top_processes" >> top5_process_IMESTAMP

=========================================================


#!/bin/bash

# Use the top command to get CPU usage, suppress header, and limit to 1 iteration
cpu_usage=$(top -b -n 1 | grep '%Cpu(s):' | awk '{print $2}')

# Print the CPU usage
echo "Current CPU Usage: $cpu_usage%"


==============================================================================

grep 'cpu '  | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}'

cat /proc/cpuinfo | grep 'cpu '  | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}'



===================================================================================================
patching 
installing 

zoopker ()
broker ()
controlle ()


#!/bin/bash

# Update the system by installing available updates
updating java 
updatibg kernal
updating java paths with new version

# Clean up cached package files to save disk space
sudo yum clean all

# Print a message indicating the patching process is complete
echo "Patching complete."



====================================================

postpatching.sh 


prepatching.sh



===========================================================================================================================================

