#!/usr/bin/perl
#
# MySQL simple Perl replication check
# To see if replication is running
# 

use strict;
use Sys::Hostname;
use Net::SMTP;
my $hostname = hostname;
my $user = "";
my $passwd = "";
my $mysql = "/usr/bin/mysql";
my $host = "$ARGV[0]";

use vars qw($username $passwd $mysql $SR $SRV $LE $LEV $SB $SBV $smtp);

{
open (STATUS, "$mysql --host=$host --user=$user --password=$passwd -e 'SHOW SLAVE STATUS\\G;' |" ) or die "Cannot exec command!";
}

while (<STATUS>) {
        chomp $_;
#        print $_;
        
          if (/(Slave_SQL_Running:)(\s\w+)/i) {
            $SR = $1;
            $SRV = $2;
          }
          
          if (/(Last_Errno:)(\s\d+)/) {
            $LE = $1;
            $LEV = $2;
          }
          
          if (/(Seconds_Behind_Master:)(\s\w+)/i) {
            $SB = $1;
            $SBV = $2;
          }


    }
    
    
if (($SRV != "Yes" ) || ($LEV != 0) || ($SBV > 2 ) ) {

    $smtp = Net::SMTP->new('localhost');
    $smtp->debug(0);
    $smtp->mail('root@mysqlserver');
    $smtp->to('some@somewhere', 'some2@somwhere');
    $smtp->data();
    $smtp->datasend("Subject: MySQL replication on $hostname problem\n");
    $smtp->datasend("From: root\n");
    $smtp->datasend("To: some\@somewhere\n");
    $smtp->datasend("\n");
    $smtp->datasend("Replication seems b0rken on host $hostname with values:\n $SR $SRV\n $LE $LEV\n $SB $SBV\n");
    $smtp->dataend();
    $smtp->quit;

#	print "Replication seems b0rken on host $hostname with values:\n $SR $SRV\n $LE $LEV\n $SB $SBV\n";
}
