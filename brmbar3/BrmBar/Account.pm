package BrmBar::Account;

use strict;
use warnings;
use v5.10;

use utf8;
use encoding::warnings;
use open qw(:encoding(UTF-8));

use Moose;
use Carp;

has 'db' => (is => 'ro', isa => 'DBI::db', required => 1);
has 'id' => (is => 'ro', isa => 'Int');
has 'name' => (is => 'ro', isa => 'Str');
has 'acctype' => (is => 'ro', isa => 'Str');
has 'currency' => (is => 'ro', isa => 'BrmBar::Currency');


sub load_by_barcode {
	my ($class, %opts) = @_;

	defined $opts{db} or croak "db parameter missing";

	my $q = $opts{db}->prepare('SELECT account FROM barcodes WHERE barcode = ?');
	$q->execute($opts{barcode});
	($opts{id}) = $q->fetchrow_array();
	defined $opts{id} or return undef;

	delete $opts{barcode};
	return $class->load(%opts);
}

# Constructor for existing account
sub load {
	my ($class, %opts) = @_;

	defined $opts{db} or croak "db parameter missing";

	if (defined $opts{id}) {
		my $q = $opts{db}->prepare('SELECT name FROM accounts WHERE id = ?');
		$q->execute($opts{id});
		($opts{name}) = $q->fetchrow_array();

	} elsif (defined $opts{name}) {
		my $q = $opts{db}->prepare('SELECT id FROM accounts WHERE name = ?');
		$q->execute($opts{name});
		($opts{id}) = $q->fetchrow_array();
	}

	my $q = $opts{db}->prepare('SELECT currency, acctype FROM accounts WHERE id = ?');
	$q->execute($opts{id});
	@opts{'currency', 'acctype'} = $q->fetchrow_array();

	$opts{currency} = BrmBar::Currency->load(db => $opts{db}, id => $opts{currency});

	my $self = $class->new(%opts);
	return $self;
}

# Constructor for new account
sub create {
	my ($class, %opts) = @_;

	defined $opts{db} or croak "db parameter missing";
	defined $opts{name} or croak "name parameter missing";
	defined $opts{currency} or croak "currency parameter missing";
	defined $opts{acctype} or croak "acctype parameter missing";

	my $q = $opts{db}->prepare('INSERT INTO accounts (name, currency, acctype) VALUES (?, ?, ?) RETURNING id');
	$q->execute($opts{name}, $opts{currency}->id(), $opts{acctype});
	($opts{id}) = $q->fetchrow_array();

	my $self = $class->new(%opts);
	return $self;
}

sub balance {
	my ($self) = @_;

	my $q = $self->db()->prepare('SELECT SUM(amount) FROM transaction_splits WHERE account = ? AND side = ?');

	$q->execute($self->id(), 'debit');
	my ($debit) = $q->fetchrow_array;
	$debit ||= 0;

	$q->execute($self->id(), 'credit');
	my ($credit) = $q->fetchrow_array;
	$credit ||= 0;

	return ($debit - $credit);
}

sub balance_str {
	my ($self) = @_;
	return $self->currency()->str($self->balance());
}

sub negbalance_str {
	my ($self) = @_;
	return $self->currency()->str(-$self->balance());
}

sub debit {
	my ($self, $tr, $amount, $memo) = @_;
	$self->_transaction_split($tr, 'debit', $amount, $memo);
}

sub credit {
	my ($self, $tr, $amount, $memo) = @_;
	$self->_transaction_split($tr, 'credit', $amount, $memo);
}

# Common part of credit(), debit()
sub _transaction_split {
	my ($self, $tr, $side, $amount, $memo) = @_;
	$self->db()->prepare('INSERT INTO transaction_splits (transaction, side, account, amount, memo) VALUES (?, ?, ?, ?, ?)')->execute($tr, $side, $self->id(), $amount, $memo);
}

1;
