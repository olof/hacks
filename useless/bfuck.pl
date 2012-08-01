#!/usr/bin/perl
use warnings FATAL => 'all';
use strict;
$|=1;

package Buffer;

sub new {
	bless {
		bp => 0,
		b => [0]
	}
}

{
	no warnings 'uninitialized';
	sub inc { my ($s)=@_; $s->set(($s->get + 1) % 0x100) }
	sub dec { my ($s)=@_; $s->set(+($s->get - 1) % 0x100) }
}

sub next { my ($s)=@_; ++$s->{bp}; }
sub prev { my ($s)=@_; --$s->{bp}; } # it's undef to do < when bp is 0
sub get  { my ($s) = @_; $s->{b}->[$s->{bp}] }
sub set  { my ($s, $v) = @_; $s->{b}->[$s->{bp}] = $v }

package Source;

sub new {
	my $class = shift;
	my %in = ( @_ );
	bless {
		buffer => $in{buffer} // Buffer->new,
		src => [ grep /[-+<>,.\[\]]/, split //, join '', @{$in{src}} ],
	}
}

sub step {
	my $self = shift;
	my $tok = shift @{$self->{src}} or return;

	my $table = {
		'-' => sub { $self->dec },
		'+' => sub { $self->inc },
		'<' => sub { $self->prev },
		'>' => sub { $self->next },
		',' => sub { $self->get },
		'.' => sub { $self->put },
		'[' => sub { $self->gen_subexpr },
		']' => sub { $self->noop }, # syntax error, unexpected ]
	};

	$table->{$tok}->();

	return 1;
}

sub gen_subexpr {
	my $self = shift;
	
	my $subloops = 1; # number of 
	my @sub;
	for (@{$self->{src}}) {
		--$subloops or last if $_ eq ']';
		++$subloops if $_ eq '[';
		push @sub, $_;
	}

	Source->new(
		buffer => $self->{buffer},
		src => [@sub]
	)->run while $self->{buffer}->get;

	splice @{$self->{src}}, 0, @sub + 1;
}

sub dec  { shift->{buffer}->dec; }
sub inc  { shift->{buffer}->inc; }
sub prev { shift->{buffer}->prev; }
sub next { shift->{buffer}->next; } 
sub get  { shift->{buffer}->set(ord getc); }
sub put  { print chr shift->{buffer}->get; }
sub run  { my $self = shift; while($self->step) {} }
sub noop { 'this is actually a syntax error' }

package main;
Source->new( src => [<>] )->run;
