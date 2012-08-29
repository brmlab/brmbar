package BrmBar::Currency;

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


# Default wallet currency
sub default {
	my ($class, %opts) = @_;

	return $class->load(db => $opts{db}, name => 'Kč');
}

# Constructor for existing currency
sub load {
	my ($class, %opts) = @_;

	defined $opts{db} or croak "db parameter missing";

	if (defined $opts{id}) {
		my $q = $opts{db}->prepare('SELECT name FROM currencies WHERE id = ?');
		$q->execute($opts{id});
		($opts{name}) = $q->fetchrow_array();

	} elsif (defined $opts{name}) {
		my $q = $opts{db}->prepare('SELECT id FROM currencies WHERE name = ?');
		$q->execute($opts{name});
		($opts{id}) = $q->fetchrow_array();
	}

	my $self = $class->new(%opts);
	return $self;
}

# Constructor for new currency
sub create {
	my ($class, %opts) = @_;

	defined $opts{db} or croak "db parameter missing";
	defined $opts{name} or croak "name parameter missing";

	my $q = $opts{db}->prepare('INSERT INTO currencies (name) VALUES (?) RETURNING id');
	$q->execute($opts{name});
	($opts{id}) = $q->fetchrow_array();

	my $self = $class->new(%opts);
	return $self;
}


# Set exchange rate against $other (BrmBar::Currency):
# $buy is the price of $self in means of $other when buying it (into brmbar)
# $sell is the price of $self in means of $other when selling it (from brmbar)
sub set_rate {
	my ($self, $other, $buy, $sell) = @_;

	my $qs = $self->db()->prepare("SELECT rate FROM exchange_rates WHERE target = ? AND source = ?");
	my $qu = $self->db()->prepare("UPDATE exchange_rates SET rate = ?, rate_dir = ? WHERE target = ? AND source = ?");
	my $qi = $self->db()->prepare("INSERT INTO exchange_rates (target, source, rate, rate_dir) VALUES (?, ?, ?, ?)");

	$qs->execute($self->id(), $other->id());
	if ($qs->fetchrow_array) {
		$qu->execute($buy, 'target_to_source');
	} else {
		$qi->execute($self->id(), $other->id(), $buy, 'target_to_source');
	}

	$qs->execute($other->id(), $self->id());
	if ($qs->fetchrow_array) {
		$qu->execute($sell, 'source_to_target');
	} else {
		$qi->execute($other->id(), $self->id(), $sell, 'source_to_target');
	}
}

# Return ($buy, $sell) rates of $self in relation to $other (BrmBar::Currency):
# $buy is the price of $self in means of $other when buying it (into brmbar)
# $sell is the price of $self in means of $other when selling it (from brmbar)
sub rates {
	my ($self, $other) = @_;

	my $qs = $self->db()->prepare("SELECT rate, rate_dir FROM exchange_rates WHERE target = ? AND source = ?");

	$qs->execute($self->id(), $other->id());
	my ($buy_rate, $buy_rate_dir) = $qs->fetchrow_array;
	defined $buy_rate or croak "unknown conversion ".$other->name()." to ".$self->name();
	my $buy = $buy_rate_dir eq 'target_to_source' ? $buy_rate : 1/$buy_rate;

	$qs->execute($other->id(), $self->id());
	my ($sell_rate, $sell_rate_dir) = $qs->fetchrow_array;
	defined $sell_rate or croak "unknown conversion ".$self->name()." to ".$other->name();
	my $sell = $sell_rate_dir eq 'source_to_target' ? $sell_rate : 1/$sell_rate;

	return ($buy, $sell);
};

sub convert {
	my ($self, $amount, $target) = @_;

	my $q = $self->db()->prepare("SELECT rate, rate_dir FROM exchange_rates WHERE target = ? AND source = ? AND valid_since <= NOW() ORDER BY valid_since ASC LIMIT 1");
	$q->execute($target->id(), $self->id());
	my ($rate, $rate_dir) = $q->fetchrow_array();

	defined $rate or croak "unknown conversion ".$self->name()." to ".$target->name();

	return $rate_dir eq 'source_to_target' ? $amount * $rate : $amount / $rate;
}

sub str {
	my ($self, $amount) = @_;
	return $amount . ' ' . $self->name();
}

1;
