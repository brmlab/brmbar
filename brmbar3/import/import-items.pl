# stdin in format: 8594002931643;Brmburky - hov.na cibul;-15
use v5.12;
while (<>) {
	chomp;
	say STDERR "--- $_";
	my ($barcode, $name, $price) = split(/;/);
	$price = -$price;
	print <<EOT
INSERT INTO currencies (name) VALUES ('$name');
INSERT INTO accounts (name, currency, acctype) VALUES ('$name', (SELECT id FROM currencies WHERE name = '$name'), 'inventory');
INSERT INTO exchange_rates (target, source, rate, rate_dir) VALUES ((SELECT id FROM currencies WHERE name = '$name'), (SELECT id FROM currencies WHERE name = 'Kč'), $price, 'target_to_source');
INSERT INTO exchange_rates (target, source, rate, rate_dir) VALUES ((SELECT id FROM currencies WHERE name = 'Kč'), (SELECT id FROM currencies WHERE name = '$name'), $price, 'source_to_target');
INSERT INTO barcodes (barcode, account) VALUES ('$barcode', (SELECT id FROM accounts WHERE name = '$name'));
EOT
}
