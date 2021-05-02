# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Fr 2020-03-13 00:42:22 CET
# Last Modified:  So 2021-05-02 19:39:41 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Helpers;

use warnings;
use strict;

use Carp;
use Data::Dumper;
use Module::Find;
use Text::Trim;
use Try::Tiny;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(@Modules);
our @EXPORT_OK = qw(modulename uidlabel unpackundef);
our %EXPORT_TAGS = ();

our @Modules = useall 'CAE::DYNA::Keyword';


=head1 NAME

CAE::DYNA::Helpers - Base module for common auxiliary subroutines

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Helpers;

=head1 DESCRIPTION

=head1 SUBROUTINES

=over 4

=cut

#-------------------------------------------------------------------------------
#     M O D U L E N A M E
#-------------------------------------------------------------------------------

=item modulename

...

=cut

# Lookup table
my %modulename = (
    # Keyword
    '*BOUNDARY_PRESCRIBED_FINAL_GEOMETRY' => 'Boundary_Prescribed_Final_Geometry',
    '*DEFINE_CURVE'                       => 'Define_Curve',
    '*ELEMENT_BEAM'                       => 'Element_Beam',
    '*ELEMENT_SHELL'                      => 'Element_Shell',
    '*HOURGLASS'                          => 'Hourglass',
    '*MAT_ELASTIC'                        => 'Mat_Elastic',
    '*MAT_NULL'                           => 'Mat_Null',
    '*MAT_RIGID'                          => 'Mat_Rigid',
    '*MAT_PLASTIC_KINEMATIC'              => 'Mat_Plastic_Kinematic',
    '*MAT_SIMPLIFIED_RUBBER/FOAM'         => 'Mat_Simplified_Rubber_Foam',
    '*MAT_VISCOELASTIC'                   => 'Mat_Viscoelastic',
    '*NODE'                               => 'Node',
    '*PART'                               => 'Part',
    '*TITLE'                              => 'Title',
    '*SECTION_BEAM'                       => 'Section_Beam',
    '*SECTION_SHELL'                      => 'Section_Shell',
    '*SET_SHELL'                          => 'Set_Shell',
    '*SET_SHELL_LIST'                     => 'Set_Shell',
);

# Loop over existing keys
for my $keyword (keys %modulename)
{
    # Add basename prefix
    my $class = 'CAE::DYNA::Keyword::' . $modulename{$keyword};

    # Adjust hash value
    $modulename{$keyword} = $class;

    # Assess classname by variable
    try {
        # Add hash entry with TITLE option
        $modulename{ $keyword . '_TITLE' } = $class
            if $class->meta->has_attribute('title_ok');
    }
    catch
    {
        # Internal error
        confess "*** ERROR\n" .
                "    Class '$class' defined in 'modulename' does not exist\n";
    }
}

# Lookup name of Perl module from LS-DYNA keyword
sub modulename
{
    #
    my $keyword = shift;

    # Assert string variable

    # Convert to uppercase
    $keyword = uc($keyword);

    # Lookup classname
    my $result = $modulename{$keyword};

    # Check result
    if (defined $result)
    {
        # Issue warning if module is not listed in available modules
        carp "Module '$result' not listed in available modules"
            unless grep { m/^$result$/ } @Modules;
    }
    else
    {
        # Issue warning if lookup failed
        carp "Module for keyword '$keyword' not implemented yet";
    }

    # Return result
    return $result;
}


#-------------------------------------------------------------------------------
#     U I D L A B E L
#-------------------------------------------------------------------------------

=item uidlabel

...

=cut

# UID labels lookup table
my %uidlabel = (
    # Module suffix
    'Boundary_Prescribed_Final_Geometry' => 'BPFGID',
    'Define_Curve'                       => 'LCID',
    'Element_Beam'                       => 'EID',
    'Element_Shell'                      => 'EID',
    'Hourglass'                          => 'HGID',
    'Mat_Elastic'                        => 'MID',
    'Mat_Null'                           => 'MID',
    'Mat_Plastic_Kinematic'              => 'MID',
    'Mat_Rigid'                          => 'MID',
    'Mat_Simplified_Rubber_Foam'         => 'MID',
    'Mat_Viscoelastic'                   => 'MID',
    'Node'                               => 'NID',
    'Part'                               => 'PID',
    'Section_Beam'                       => 'SECID',
    'Section_Shell'                      => 'SECID',
    'Set_Shell'                          => 'SID',
    'Title'                              => 'TITLE',
);

# Issue warning if there are any unregistered modules available
foreach my $test (@Modules)
{
    carp "Module '$test' available, but not registered"
        unless grep { m/^$test$/ }
            sort map { "CAE::DYNA::Keyword::$_" } keys %uidlabel;
}

# Lookup UID label from Perl module name
sub uidlabel
{
    # Fetch argument
    my $classname = shift;

    # Remove baseclass prefix
    $classname =~ s/^CAE::DYNA::Keyword:://i;

    # Initialize result
    my $result;

    # Check if there is a direct match
    if (exists $uidlabel{$classname})
    {
        # Direct match
        $result = $uidlabel{$classname};
    }
    else
    {
        # Check if there are pattern matches with classname as prefix
        my @keys = grep { m/^$classname/i } keys %uidlabel;

        # Check number of matches
        if (scalar @keys == 1)
        {
            # Unique match
            $result = $uidlabel{$keys[0]};
        }
        elsif (scalar @keys > 1)
        {
            # Check if all matches point to same topclass
            my @vals = map { $uidlabel{$_} } @keys;
            my @uniq = do { my %seen; grep { !$seen{$_}++ } @vals };

            # If there is 1 match, get it
            $result = shift @uniq if scalar @uniq == 1;

            # Ambigous matches
            carp "Cannot handle ambiguous classname '$classname'" if @uniq;
        }
        else
        {
            # No matches
            carp "Failed to determine top class for classname '$classname'";
        }
    }

    # Return result
    return $result;
}


#-------------------------------------------------------------------------------
#     U N P A C K U N D E F
#-------------------------------------------------------------------------------

=item unpackundef

...

=cut

# Unpack LS-DYNA keyword row to values and undefine empty strings
sub unpackundef
{
    #
    my ($fmt, $str) = @_;

    #
    map {
        my $val = $_;
        if (defined $val)
        {
            $val = trim($val);
            $val = undef if $val eq '';
        }
        $val;
    }
    unpack($fmt, $str);
}

=back

=head1 DEPENDENCIES

=head1 BUGS AND LIMITATIONS

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2021 Matthias Boljen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut

1;
