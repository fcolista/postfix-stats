#!/usr/bin/perl
#
# $jwk: update-mailstats.pl,v 1.6 2007/05/30 01:28:33 jwk Exp $
#
# Copyright 2006-2007 Joel Knight
# Copyright Craig Sanders 1999
#
# this script is licensed under the terms of the GNU GPL.
#
#
# [2006.11.12]


use DB_File;
use File::Tail;
$debug = 0;

$mail_log = '/var/log/messages';
$stats_file = '/tmp/postfix-stats.db';


$db = tie(%stats, "DB_File", "$stats_file", O_CREAT|O_RDWR, 0644, $DB_HASH) 
	|| die ("Cannot open $stats_file");

my $logref = tie(*LOG, "File::Tail", ( name=>$mail_log, debug=>$debug ));

#  taken from perlmonks.com - http://www.perlmonks.org/index.pl?node_id=131513
close STDIN;
close STDOUT;
close STDERR;
if (open(DEVTTY, "/dev/tty")) {
	ioctl DEVTTY, 0x20007471, 0;
	close DEVTTY;
}
open STDIN, "</dev/null";
open STDOUT, ">/dev/null";
open STDERR, ">&STDOUT";
fork && exit;

foreach (keys %stats) {
	$stats{$_} = 0;
}
$db->sync;

while (<LOG>) {
	if (/status=sent/) {
		next unless (/ postfix\//);
		if (/relay=([^,]+)/o) {
			$relay = $1;
		} 
		if ($relay !~ /\[/o ) {
			$stats{"sent:$relay"} += 1;
		} else {
			$stats{"sent:smtp"} += 1;
		} 
	} elsif (/status=bounced.+said: (\d)\d\d/) {
		$stats{"smtp:$1xx"} += 1;
	} elsif (/smtpd.*client=/) {
		$stats{"recv:smtp"} += 1;
	} elsif (/pickup.*(sender|uid)=/) {
		$stats{"recv:local"} += 1;
	} elsif (/NOQUEUE: reject.+\]: (\d)\d\d/) {
		$stats{"smtpd:$1xx"} += 1;
	}
	$db->sync;
} 

$db->sync;
untie $logref;
untie %stats;

