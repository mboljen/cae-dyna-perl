use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'CAE::DYNA::Keyfile',
    AUTHOR        => q{Matthias Boljen <mboljen@online>},
    VERSION_FROM  => 'lib/CAE/DYNA/Keyfile.pm',
    ABSTRACT_FROM => 'lib/CAE/DYNA/Keyfile.pm',
    LICENSE       => 'MIT',
    PL_FILES      => {},
    EXE_FILES     => [],
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Carp'               => 0,
        'Data::Dumper'       => 0,
        'File::Slurp'        => 0,
        'List::Util'         => 0,
        'Math::Vector::Real' => 0,
        'Module::Find'       => 0,
        'Moose'              => 0,
        'Readonly'           => 0,
        'Regexp::Common'     => 0,
        'Text::Trim'         => 0,
        'Try::Tiny'          => 0,
        'Scalar::Util'       => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'CAE-DYNA-*' },
);
