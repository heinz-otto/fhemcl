# fhemcl
FHEM HTTP Client

Basic Feature:
* For localhost only portnumber is needed
* support full qualified url, see examples below
* take care for csrfToken
* support FHEM Commands from inputline, Pipeline, Textfile
* urlencode the commandline
* basic parsing of the HTML Output and returns only Text

Usage:
* fhemcl [http://hostname:]portnumber "FHEM command1" "FHEM command2"
* fhemcl [http://user:password@hostname:]portnumber filename
* echo -e "set Aktor01 toggle" | fhemcl [http://hostname:]portnumber
