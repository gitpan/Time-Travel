# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::Simple tests=>4;
use Time::Travel;
use Time::ParseDate;
my $time0 = new Time::Travel(localtime);
my $time1 = new Time::Travel(localtime);
my @param1 = qw(7dy 60hr 394mn 1222sc);
my @param2 = qw(-7dy 60hr -394mn 1222sc);
my $sec1 = &convert_to_sec(@param1);
my $sec2 = &convert_to_sec(@param2);
my $t0 = $time0->land();
$time0->travel(\@param1);
my $t1 = $time0->land();
$time1->travel(\@param2);
my $t2 = $time1->land();
my $s0 = parsedate($t0,UK=>1,TIMEFIRST=>1);
my $s1 = parsedate($t1,UK=>1,TIMEFIRST=>1);
my $s2 = parsedate($t2,UK=>1,TIMEFIRST=>1);
ok(defined $time0);
ok($s1-$s0 == $sec1);
ok($s2-$s0 == $sec2);
$time0 = new Time::Travel(07,13,16,19,5,2003);
ok(defined $time0);

sub convert_to_sec {

    my @param = @_;
    my $sec = 0;
    my %step;
    
    for (@param) {
	my ($value,$unit) = (/(\-?\d+)(sc|mn|hr|dy|mo|yr)/i);
	$step{$unit} = $value;
    }
    $sec = $step{sc} + 60 * ($step{mn} + 60 * ($step{hr} + 24 * $step{dy}));
    return $sec;
}
