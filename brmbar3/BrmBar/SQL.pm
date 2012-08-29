package BrmBar::SQL;

use warnings;
use strict;
use v5.10;

use utf8;
use encoding::warnings;
use open qw(:encoding(UTF-8));

use DBI;

sub init {
	my ($sqlconf) = @_;
	my $db = DBI->connect("dbi:Pg:dbname=brmbar", '', '', {AutoCommit => 1, RaiseError => 1, pg_enable_utf8 => 1})
		or die "Cannot open db: ".DBI->errstr;
	$db;
}

1;
