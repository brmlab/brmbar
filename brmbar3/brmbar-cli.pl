#!/usr/bin/perl -CSA

use warnings;
use strict;
use v5.10;

use utf8;
use encoding::warnings;
use open qw(:encoding(UTF-8));

use lib qw(.);
use BrmBar::SQL;
use BrmBar::Account;
use BrmBar::Shop;

my $db = BrmBar::SQL->init();
my $shop = BrmBar::Shop->new_with_defaults(db => $db);
my $currency = $shop->currency();

my ($active_inv_item, $active_credit);

while (<>) {
	chomp;
	my $barcode = $_;

	if ($barcode =~ /^\$/) {
		# Credit replenishment
		my %credits = ('$02' => 20, '$05' => 50, '$10' => 100, '$20' => 200, '$50' => 500, '$1k' => 1000);
		my $credit = $credits{$barcode};
		if (not defined $credit) {
			say("Unknown barcode: $barcode");
			next;
		}

		undef $active_inv_item;
		$active_credit = $credit;
		next;
	}

	if ($barcode eq 'SCR') {
		say("SHOW CREDIT");
		undef $active_inv_item;
		undef $active_credit;
		# In next iteration, person's barcode will for sure not be charged anything
		next;
	}

	my $acct = BrmBar::Account->load_by_barcode(db => $db, barcode => $barcode);
	if (not $acct) {
		say("Unknown barcode: $barcode");
		next;
	}

	if ($acct->acctype() eq 'debt') {
		if (defined $active_inv_item) {
			my $cost = $shop->sell(item => $active_inv_item, user => $acct);
			say($acct->name()." has bought ".$active_inv_item->name()." for ".$currency->str($cost)." and now has ".$acct->negbalance_str()." balance");
		} elsif (defined $active_credit) {
			$shop->add_credit(credit => $active_credit, user => $acct);
			say($acct->name()." has added ".$currency->str($active_credit)." credit");
		} else {
			say($acct->name()." has ".$acct->negbalance_str()." balance");
		}

		undef $active_inv_item;
		undef $active_credit;

	} elsif ($acct->acctype() eq 'inventory') {
		my ($buy, $sell) = $acct->currency()->rates($currency);
		say($acct->name()." costs ".$currency->str($sell)." with ".$acct->balance()." in stock");

		$active_inv_item = $acct;
		undef $active_credit;

	} else {
		say("invalid account type ".$acct->acctype());
		undef $active_inv_item;
		undef $active_credit;
	}
}
