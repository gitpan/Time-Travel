use 5.006001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Time::Travel',
    'VERSION_FROM'	=> 'Travel.pm',
    'PREREQ_PM'		=> {
	'Date::Parse' => '2.20',
	'Time::DaysInMonth' =>'96.032702',
	'Time::ParseDate'=>'101',
    }
	      );
