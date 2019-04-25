# fhemcl
FHEM HTTP Client

Basic Feature:
* For localhost only portnumber is needed
* take care for csrfToken
* support FHEM Commands from inputline, Pipeline, Textfile
* urlencode the commandline
* basic parsing of the HTML Output and returns only Text

Usage:
* 'fhemcl [http://<hostName>:]<portNummer> "FHEM command1" "FHEM command2"'
* 'fhemcl [http://<hostName>:]<portNummer> filename'
* 'echo -e "set Aktor01 toggle" | fhemcl [http://<hostName>:]<portNumber>'
