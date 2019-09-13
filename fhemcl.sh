#!/bin/bash
# Heinz-Otto Klas 2019
# send commands to FHEM over HTTP
# if no Arguments use default http://localhost:8083
port=8083
host=localhost
prot=http
# Functions
function usage {
	echo ${0##*/}' <hosturl> "FHEM command1" "FHEM command2"'
	echo ${0##*/}' <hosturl> filename'
	echo 'lines from pipe like echo -e "set Aktor01 toggle" | '${0##*/}' [<hosturl>]'
	echo "<hosturl> default is $prot://$host:$port"
	echo '<hosturl> Argument could be any part of http://user:password@hostName:portNumber'
	echo '          except user:password@ any missing part is added from default'
     exit 1
}
#End Functions
# Test option and show Helpmessage and exit
if [[ $1 == -h ]]
 then
    usage
fi
# Test the first argument and build the hosturl
if [ $# -eq 0 ]
then
    arr=($prot //$host $port) # If no Argument use default
else
    IFS=:                     # split the first Argument
    arr=($1)
    IFS=
fi
# Test if portnumber at last position
if  echo "${arr[-1]}" | grep -q -E '^[[:digit:]]+$'
then
    if [ ${#arr[@]} -eq 1 ]  # If only portnumber?
    then
       arr=($host ${arr[0]}) # add default host to array
    fi
else
    arr[${#arr[@]}]=$port    # no portnumber add default port to array
fi

if [[ "${arr[1]}" != //* ]]  # exist already // 
then
   arr=($prot //${arr[*]})    # add default protocol :// to the final url
fi
hosturl=$(IFS=":";echo "${arr[*]}") # build the full url from the array together

# get Token and Status
token=;status=
while IFS=':' read key value; do
    case "$key" in
        X-FHEM-csrfToken) token=${value//[[:blank:]]/} ;;
        HTTP*) status="$key"                           ;;
     esac
done < <(curl -s -D - "$hosturl/fhem?XHR=1")
# this should be extended
# now only zero message detected
if [ -z "${status}" ]; then 
        echo "no response from $hosturl"
	exit 1
fi

# reading FHEM command, from Pipe, File or Arguments 
# Check to see if a pipe exists on stdin.
cmdarray=()
if [ -p /dev/stdin ]; then
        # we read the input line by line
        while IFS= read -r line; do
              cmdarray+=("${line}")
        done
else
    # Checking the 2 parameter: filename exist or simple commands
    if [ -f "$2" ]; then
        # echo "Reading File: ${2}"
        readarray -t cmdarray < "${2}"
    else
    # Reading further parameters
        for ((a=2; a<=${#}; a++)); do
            # echo "command specified: ${!a}"
            cmdarray+=("${!a}")
        done
    fi
fi
# if cmdarray is empty show Helpmessage and exit
if [ ${#cmdarray[*]} -eq 0 ]; then
    echo "no command given, hosturl was $hosturl"
    usage
fi
# loop over all lines stepping up. For stepping down (i=${#cmdarray[*]}; i>0; i--)
for ((i=0; i<${#cmdarray[*]}; i++));do 
    # concat def lines with ending \ to the next line, remove any \r from line
    cmd=${cmdarray[i]//[$'\r']} 

    while [ "${cmd:${#cmd}-1:1}" = '\' ];do 
          ((i++))
          cmd=${cmd::-1}$'\n'${cmdarray[i]//[$'\r']}
    done

    # echo "proceeding Line $((i+1)) : ${cmd}"
    # urlencode loop over String
    cmdu=''
    for ((pos=0;pos<${#cmd};pos++)); do
        c=${cmd:$pos:1}
        [[ "$c" =~ [a-zA-Z0-9\.\~\_\-] ]] || printf -v c '%%%02X' "'$c"
        cmdu+="$c"
    done
    cmd=$cmdu
    # send command to FHEM and filter the output (tested with list...).
    # the HTML Output is filtered (command sed -n) to the div container "content", all lines between <div ... </div> (included)
    # first sed -e stripped the line with div itself, second " -e" stripped the lines with pre
    # third " -e" removes all remaining html Tags - and we get plain formatted Text
    # may be the argument -m 15 is usefull
    curl -s --data "fwcsrf=$token" "$hosturl/fhem?cmd=$cmd" | sed -n '/<div.*content/,/<\/div>/p' | sed -e '/div/d' -e '/\/pre>/d' -e 's/<[^>]*>//g'
done
