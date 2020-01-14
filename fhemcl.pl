#!/usr/bin/env perl
# Heinz-Otto Klas 2019
# send commands to FHEM over HTTP
# if no Argument, show usage

use strict;
use warnings;
use URI::Escape;
use LWP::UserAgent;

my $token;
my $hosturl;
my $fhemcmd;

 if ( not @ARGV ) {
     print 'fhemcl Usage',"\n";
     print 'fhemcl [http://<hostName>:]<portNummer> "FHEM command1" "FHEM command2"',"\n";
     print 'fhemcl [http://<hostName>:]<portNummer> filename',"\n";
     print 'echo -e "set Aktor01 toggle" | fhemcl [http://<hostName>:]<portNumber>',"\n";
     exit;
 }

if ($ARGV[0] !~ m/:/) {
   if ($ARGV[0] eq ($ARGV[0]+0)) { # isnumber?
       $hosturl = "http://localhost:$ARGV[0]";
   }
   else {
       print "$ARGV[0] is not a Portnumber";
       exit(1);
   }
}
else {
    $hosturl = $ARGV[0];
}

# get token 
my $ua = new LWP::UserAgent;
my $url = "$hosturl/fhem?XHR=1/";
my $resp = $ua->get($url);
   $token = $resp->header('X-FHEM-CsrfToken');

my @cmdarray ;

# test the pipe and read 
if (-p STDIN) {
   while(<STDIN>) {
       s/\r[\n]*/\n/gm;      #remove any \r from $_
       chomp($_);
       push(@cmdarray,$_);
   }
}
# second Argument is file or command?
if ($ARGV[1] and -e $ARGV[1]) {
    open(DATA, '<', $ARGV[1]);
    while(<DATA>) {
       s/\r[\n]*/\n/gm;      #remove any \r from $_
       chomp($_);
       push(@cmdarray,$_);
    }
    close(DATA);
}
else {
    for(my $i=1; $i < int(@ARGV); $i++) {
    push(@cmdarray, $ARGV[$i]);
    }
}
#execute commands and print response from FHEMWEB 
for(my $i = 0; $i < @cmdarray; $i++) {
    # concat def lines with ending \ to the next line
    my $cmd = $cmdarray[$i];
    while ($cmd =~ m/\\$/) {
        $i++;
        $cmd = substr($cmd,0, -1)."\n".$cmdarray[$i];
    };
    # url encode the cmd
    $fhemcmd = uri_escape($cmd);
    # print "proceeding line ".eval($i+1)." : $fhemcmd\n";
    $url = "$hosturl/fhem?cmd=$fhemcmd&fwcsrf=$token&XHR=1";
    $resp = $ua->get($url)->content;
    print $resp
}
