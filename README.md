# FHEM HTTP Client
* send FHEM commands over HTTP and get clear Text response

Basic Feature:
* For localhost only portnumber is needed
* support full qualified url, see examples below
* support csrfToken and basicauth
* support FHEM Commands from inputline, Pipeline, Textfile
* urlencode the commandline
* Answer from FHEMWEB returns only Text similar to fhem.pl client mode

Usage:
```
fhemcl [http://[user:password@]hostname:]portnumber "FHEM command1" "FHEM command2"
fhemcl [http://[user:password@]hostname:]portnumber filename
echo -e "set Aktor01 toggle" | fhemcl [http://[user:password@]hostname:]portnumber
```

## Usage Scenarios
For redirecting the stdout of another Program line per line for logging to FHEM
### Powershell: 
```
| % {"set Sicherung " + $_ } | fhemcl.ps1 [http://[user:password@]hostname:]portnumber
```
### Bash:
```
| while IFS= read -r line; do echo "set Sicherung ${line}";done | bash fhemcl.sh [http://[user:password@]hostname:]portnumber
```
### get the Script inside your machine:
```
wget -OutFile fhemcl.ps1 https://raw.githubusercontent.com/heinz-otto/fhemcl/master/fhemcl.ps1
wget -O fhemcl.pl https://raw.githubusercontent.com/heinz-otto/fhemcl/master/fhemcl.pl
wget -O fhemcl.sh https://raw.githubusercontent.com/heinz-otto/fhemcl/master/fhemcl.sh
```
