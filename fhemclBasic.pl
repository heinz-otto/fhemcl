sub fhemcl($$)
{
   use URI::Escape;
   use LWP::UserAgent;
     my ($hosturl,$fhemcmd) = @_;
     my $token;
   # get token 
     my $ua = new LWP::UserAgent;
     my $url = "$hosturl/fhem?XHR=1/";
     my $resp = $ua->get($url);
        $token = $resp->header('X-FHEM-CsrfToken');
   # url encode the cmd
     $fhemcmd = uri_escape($fhemcmd);
     $url = "$hosturl/fhem?cmd=$fhemcmd&fwcsrf=$token&XHR=1";
     $resp = $ua->get($url)->content;
     # cut the last character, the additional newline
     return substr $resp,0,-1
}
# Usage
#{fhemcl("http://raspib3:8083","{ReadingsVal('Melder','state','error')}")}
#{fhemcl("http://raspib3:8083","set Test2 toggle")}
#{fhemcl("http://raspib3:8083","list global")}
