package BrmBar::Shop;

use strict;
use warnings;
use v5.10;

use utf8;
use encoding::warnings;
use open qw(:encoding(UTF-8));

use Moose;
use Carp;

use BrmBar::Currency;
use BrmBar::Account;

has 'db' => (is => 'ro', isa => 'DBI::db', required => 1);
has 'currency' => (is => 'rw', isa => 'BrmBar::Currency');
has 'profits' => (is => 'ro', isa => 'BrmBar::Account'); # income account for our margins
has 'cash' => (is => 'ro', isa => 'BrmBar::Account'); # our operational ("wallet") cash account

sub new_with_defaults {
	my ($class, %opts) = @_;

	return $class->new(
		db => $opts{db},
		currency => BrmBar::Currency->default(db => $opts{db}),
		profits => BrmBar::Account->load(db => $opts{db}, name => 'BrmBar Profits'),
		cash => BrmBar::Account->load(db => $opts{db}, name => 'BrmBar Cash')
	);
}


sub sell {
	my ($self, %opts) = @_;
	my ($item, $user, $amount) = @opts{'item', 'user', 'amount'};
	$amount ||= 1;

	my ($buy, $sell) = $item->currency()->rates($self->currency());
	my $cost = $amount * $sell;
	my $profit = $amount * ($sell - $buy);

	$self->db()->begin_work();
	my $tr = $self->_transaction(responsible => $user, description => 'BrmBar sale of '.$amount.'x '.$item->name().' to '.$user->name());
	$item->credit($tr, $amount, $user->name());
	$user->debit($tr, $cost, $item->name()); # debit (increase) on a _debt_ account
	$self->profits()->debit($tr, $profit, "Margin on ".$item->name());
	$self->db()->commit();

	return $cost;
}

sub add_credit {
	my ($self, %opts) = @_;
	my ($credit, $user) = @opts{'credit', 'user'};

	$self->db()->begin_work();
	my $tr = $self->_transaction(responsible => $user, description => 'BrmBar credit replenishment for '.$user->name());
	$self->cash()->debit($tr, $credit, $user->name());
	$user->credit($tr, $credit, 'Credit replenishment');
	$self->db()->commit();
}


# This is for internal usage of the business logic
sub _transaction {
	my ($self, %opts) = @_;
	my ($responsible, $description) = @opts{'responsible', 'description'};

	$self->db()->prepare('INSERT INTO transactions (responsible, description) VALUES (?, ?)')->execute($responsible->id(), $description);
}

1;
