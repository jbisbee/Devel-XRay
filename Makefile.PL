use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'trace',
    AUTHOR              => 'Jeff <jbisbee@cpan.org>',
    VERSION_FROM        => 'lib/trace.pm',
    ABSTRACT_FROM       => 'lib/trace.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'     => 0,
        'Carp'           => 0,
        'Filter::Simple' => 0.78,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'trace-*' },
);
