# Time::Travel package - roll the time backward and forward by a given margin
# Copyright (C) 2003 Roman M. Parparov <romm@empire.tau.ac.il>
#
# This library is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Time::Travel;

use strict;
use warnings;
use Time::DaysInMonth;
use Date::Parse;
use Carp;

our @UNIT     = qw(sc mn hr dy mo yr);
our %FULLNAME = qw(sc seconds mn minutes hr hours dy days mo months yr years);
our %MAXUNIT  = qw(sc 60 mn 60 hr 24 dy 31 mo 12 yr 100000);
our %step;
our $VERSION = 0.01;
sub new {

    my $proto = shift;
    my $class = ref $proto || $proto;
    my $self;
    my $valid;
    my @time = (0,0,0,1,0,0);

    if ($#_ >= 6) {
	@time = @_[0..5];
	if ($time[5] < 200) {
	    $time[5] += 1900;
	}
    }
    elsif ($#_ == 5) {
	@time = @_;
	if ($time[5] < 200) {
	    $time[5] += 1900;
	}
    }
    elsif ($#_ > 0) {
	@time[5-$#_..5] = @_;
    }
    else {
	@time = strptime($_[0]);
	pop @time;
    }
    if ($valid = &validate(@time)) {
	carp "Invalid:$valid supplied";
	return undef;
    }
    $self->{time} = \@time;
    bless $self,$class;
    return $self;
}
sub validate {

    my @time = @_;
    my $i;
    my $valid = '';

    my $daysin = days_in($time[5],$time[4]+1);
    if (! $daysin) {
	$daysin = 0;
    }
    for ($i=5;$i>-1;$i--) {
	if ((($i == 3) && (($time[$i] > $daysin) ||
			   ($time[$i] < 1))) ||
	    (($i != 3) && (($time[$i] >= $MAXUNIT{$UNIT[$i]}) ||
			   ($time[$i] < 0)))) {
	    $valid .= " $FULLNAME{$UNIT[$i]}";
	}
    }
	  return $valid;
}
sub land {

    my $self = shift;
    $self->{time}->[4]++;
    my $show = sprintf("%02d:%02d:%02d %02d/%02d/%d\n",@{$self->{time}}[2,1,0,3,4,5]);
    $self->{time}->[4]--;
    return $show;
}
sub travel {

    my $self = shift;
    my $roll = shift;
    my @roll = @{$roll};
    my $step;
    my %step;
    my @time;
    my $i;
    my $maxval;
    my $minval;

    for (@UNIT) {
	$step{$_} = 0;
    }
    for $step (@roll) {
	my ($value,$unit) = ($step =~ /(\-?\d+)(sc|mn|hr|dy|mo|yr)/i);
	if (! (defined $value && defined $unit)) {
	    croak "Badly formatted $step\n";
	    return;
	}
	$step{lc $unit} = $value;
    }
    for ($i=0;$i<=5;$i++) {
	if ($i == 3) {
	    $minval = 1;
	    $maxval = days_in($self->{time}->[5],$self->{time}->[4]+1);
	}
	else {
	    $minval = 0;
	    $maxval = $MAXUNIT{$UNIT[$i]};
	}
	if ($step{$UNIT[$i]} != 0) {
	    $self->{time}->[$i] += $step{$UNIT[$i]};
	    my $newval = $self->{time}->[$i] % $maxval;
	    if ($i < 5) {
		$step{$UNIT[$i+1]} += ($self->{time}->[$i] - $newval) / $maxval;
	    }
	    $self->{time}->[$i] = $newval;
	}
    }
}

1;

__END__

=head1 NAME

  Time::Travel - provide a tool to travel across the time for a given
distance.

=head1 SYNOPSIS

use Time::Travel;

# initialize

my $tstr = localtime;

my $time = new Time::Travel($tstr); # or

my @tlst = localtime;

my $time = new Time;:Travel(@tlst); # or

my $time = new Time::Travel(28,14,11,19,05,2003);

my $t1 = $time->land; # source

print $t1;

$time->travel(['6mo','5dy','4hr']); # travel

print $time->land();

=head1 DESCRIPTION

The C<Time::Travel> module produces a slim, quick method to slide
across the time scale over a given period (NOT a given date).

It is much simpler and shorter than the Date::Manip and Time::Piece.
It creates an object which is in fact a reference to a six-member
array. It is possible then to travel using this object and to land
(print resulting time).

=head1 METHODS

The following methods are defined in the module:

=over 2

=item new(@TIME | $TIME);

The constructor returns a newly created object which points at a
six-member array. If the argument is a CTIME string as returned by
localtime() in scalar context, it is parsed into such array using
strptime() from Date::Parse. If the argument is a nine-member array
as returned by localtime() in list context or any other larger than
six-member list, first six members are taken. The month is considered
to be in 0..11 range as it is for localtime() and the year is
rebuilt into 4-digits number in case it is found to be less than 200.
If the given array has less than six members then it is considered
that higher precision units are omitted subsequently (i.e. if there
are only 4 members they are treated as hour, day, month and year).

The created array is then validated using internal validate()
function. If the validation fails, a warning is given and an undefined
object is returned.

=item travel([Time Distance]);

This main method shifts the time stored in the object by the given
margin which is passed as an array reference. The members of the
margin array must be of Nxx format, where N is an integer number (might
be negative) and xx is one of the following:

=over 4

=item *
sc - seconds

=item *
mn - minutes

=item *
hr - hours

=item *
dy - days

=item *
mo - months

=item *
yr - years

=back

This notation is used by GrADS (http://grads.iges.org/grads/head.html)
and I find it the best and the easiest around. The items in the margin
array might be in any order.

=item land();

After we traveled we want to land - this method constructs a CTIME
compatible string and returns it, also adjusting the month that has
been within the 0..1 range all the time. You can now print that string.

=back

=head1 BUGS

I wanted this module to be small, robust and simple therefore it does
not treat so many formats for input and output as other Time:: or Date::
modules do. But I am glad it is that way.

Years have a limitation set upwards to 100000 for sanity.

When reporting bugs/problems please include as much information as
possible.

=head1 AUTHOR

Roman M. Parparov <romm@empire.tau.ac.il>.
Special thanks to authors of the modules in C<SEE ALSO> section.

=head1 SEE ALSO

B<Time::ParseDate>, B<Date::Parse>, B<Date::Manip>, B<Time::DaysInMonth>

=head1 COPYRIGHT

Copyright 2003 Roman M. Parparov <romm@empire.tau.ac.il>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

