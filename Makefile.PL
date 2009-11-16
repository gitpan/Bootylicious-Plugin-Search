#!/usr/bin/env perl

use 5.008001;

use strict;
use warnings;

use ExtUtils::MakeMaker;

my $mm = $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
    NAME         => 'Bootylicious::Plugin::Search',
    VERSION_FROM => 'lib/Bootylicious/Plugin/Search.pm',
    ABSTRACT     => 'Search plugin for bootylicious',
    AUTHOR       => 'Viacheslav Tykhanovskyi <vti@cpan.org>',

    ($mm < 6.3002 ? () : ('LICENSE' => 'artistic_2')),

    (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires  => {perl => '5.008001'},
                resources => {
                    homepage => 'http://getbootylicious.org',
                    license  => 'http://dev.perl.org/licenses/',
                    repository =>
                      'http://github.com/vti/bootylicious-plugin-search/tree/master'
                },
                no_index => {directory => [qw/t/]}
            },
            META_ADD => {
                build_requires     => {},
                configure_requires => {}
            },
        )
    ),

    PREREQ_PM => {
        'Mojo'         => 0.999909
    },
    test => {TESTS => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t'}
);

1;
