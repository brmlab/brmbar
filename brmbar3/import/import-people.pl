# text files containing credit amount
my @users = qw(abyssal alexka axtheb aym b00lean biiter chido czestmyr da3m0n22 denisakera jam jenda jerry joe johny kappi kiki kxt lenka lui lukash nephirus niekt0 pasky pborky prusajr rainbof ramus ruza sachy sargon shady specz stevko stick sysop timthelion tlapka tma tomsuch trip tutchek uiop urcher vtec wenza zombie zufik zviratko);
print "INSERT INTO transactions (description) VALUES ('Initial balance import');\n"; # assumed to be id 1
for my $name (@users) {
	my $balance = `cat BRMBAR/DATA/$name.txt 2>/dev/null || echo -n 0`;
	my $side = 'credit';
	if ($balance < 0) {
		$balance = -$balance;
		$side = 'debit';
	}
	print <<EOT
INSERT INTO accounts (name, currency, acctype) VALUES ('$name', 1, 'debt');
INSERT INTO barcodes (barcode, account) VALUES ('$name', (SELECT id FROM accounts WHERE name = '$name'));
INSERT INTO transaction_splits (transaction, side, account, amount, memo) VALUES (1, '$side', (SELECT id FROM accounts WHERE name = '$name'), $balance, 'brmbar v1 balance');
EOT
}
