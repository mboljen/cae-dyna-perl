# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Fr 2020-03-13 00:42:22 CET
# Last Modified:  So 2021-02-07 12:02:53 CET
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyfile;

use strict;
use warnings;

use Carp;
use CAE::DYNA::Helpers;
use Data::Dumper;
use File::Slurp;
use List::Util qw(all);
use Module::Find;
use Moose;
use Readonly;
use Regexp::Common qw(number);
use Scalar::Util qw(reftype);

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

@ISA = qw(Exporter);
@EXPORT = qw();
%EXPORT_TAGS = ( 'all' => [ qw() ] );
@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

$VERSION = 0.01;

=head1 NAME

CAE::DYNA::Keyfile - Module for handling LS-DYNA keyword files

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyfile;

=head1 DESCRIPTION



=head1 METHODS

=over 4

=cut


# Invoke stringify when being used in string context
use overload '""' => 'stringify';

#
has 'filepath' => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);

#
has 'inventory' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

has 'header' => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);

#
Readonly my $ERROR   => "\n*** ERROR\n";
Readonly my $WARNING => "\n*** WARNING\n";


#-------------------------------------------------------------------------------
#     C L O N E
#-------------------------------------------------------------------------------

=item clone

...

=cut

sub clone
{
    #
    my ($self, %params) = @_;
    return $self->meta->clone_object($self, %params);
}


#-------------------------------------------------------------------------------
#     L O A D
#-------------------------------------------------------------------------------

=item load

...

=cut

#
sub load
{
    # Fetch arguments
    my ($self) = @_;

    # Empty inventory
    %{$self->inventory} = ();

    #
    $self->include($self->filepath);
}


#-------------------------------------------------------------------------------
#     S A V E
#-------------------------------------------------------------------------------

=item save

...

=cut

#
sub save
{
    # Fetch arguments
    my ($self) = @_;

    # Write file
    my $rc;
    $rc = write_file($self->filepath, $self->stringify)
            if defined $self->filepath;

    # Return result code
    return $rc;
}


#-------------------------------------------------------------------------------
#     I N C L U D E
#-------------------------------------------------------------------------------

=item include

...

=cut

#
sub include
{
    # Fetch arguments
    my ($self, $filename) = @_;

    #
    return if not defined $filename or not -f $filename;

    #
    my @file = read_file($filename)
        or confess "Cannot tie file '$filename': $!";

    # Initialize input hash
    my %input = ( 'keyword' => undef,
                  'line'    => -1,
                  'card'    => [],
                  'comment' => [] );

    # Flag to activate keyword syntax
    my $active = 0;

    # Loop over all lines
    for (my $lino = 0; $lino <= $#file; $lino++)
    {
        # Grep current line
        my $line = $file[$lino];

        chomp $line;

        # Check if new keyword arrives
        if ($line =~ m/^\*/)
        {
            # Submit buffer
            if ($active and defined $input{keyword})
            {
                #
                my @buffer;
                map { push @buffer, $file[$_]; } @{$input{card}};

                # Fetch modulename
                my $module = CAE::DYNA::Helpers::modulename($input{keyword});

                #
                if (defined $module)
                {
                    # Translate keyword data to FE objects
                    my @object =
                        $module->read({ host    => \$self,
                                        keyword => $input{keyword},
                                        buffer  => \@buffer });

                    # Add FE objects to current keyfile
                    $self->add(@object);
                }
                else
                {
                    # not implemented yet
                }
            }

            # Flush buffer
            $input{card} = [];
            $input{comment} = [];

            # Update keyword and set starting line
            $input{keyword} = undef;
            $input{line} = $lino;

            # Check if new keyword is KEYWORD
            if (not $active and $line =~ m/^\*KEYWORD\s*/i)
            {
                # Enable parsing of keyword syntax
                $active = 1;
            }
            elsif ($active and $line =~ m/^\*END\s*/i)
            {
                # Disable parsing of keyword syntax
                $active = 0;
            }
            else
            {
                # Activate new keyword
                $input{keyword} = $line;
            }

            # Proceed to next line
            next;
        }

        #
        if (defined $input{keyword})
        {
            # Get line type and save line number
            my $switch = ($line =~ m/^\$/) ? 'comment' : 'card';
            push @{$input{$switch}}, $lino;
        }
    }

    #
    return;
}


#-------------------------------------------------------------------------------
#     A D D
#-------------------------------------------------------------------------------

=item add

...

=cut

#
sub add
{
    #
    my ($self, @objects) = @_;

    #
    confess "Method 'add' cannot be invoked as subroutine"
        unless blessed($self);

    #
    while (@objects)
    {
        # Fetch object from stack
        my $object = shift @objects;

        # Get object class
        my $class = blessed($object);

        # Get UID label
        my $uidlabel = $class->uidlabel;

        #
        if (defined $object->uidset)
        {
            # Fetch object UID
            my $uid = $object->uid;

            #
            confess "Unique ID is undefined" unless defined $uid;

            #
            if (exists $self->{inventory}{$uidlabel}{$uid})
            {
                #
                warn "### WARNING\n" .
                     "    Overwriting object UID '$uid' of class '$class'";
            }

            #
            $self->{inventory}{$uidlabel}{$uid} = $object;
        }
        else
        {
            #
        }
    }
}


#-------------------------------------------------------------------------------
#     F E T C H
#-------------------------------------------------------------------------------

=item fetch

...

=cut

sub fetch
{
    #
    my ($self, $params) = @_;

    # Check parameter definition
    confess "At least 1 parameter required: 'label', 'class', 'keyword'"
        unless scalar(
            grep { defined $params->{$_} } qw(keyword class label) ) == 1;

    # Initialize parameters
    my $keyword = $params->{keyword};
    my $class   = $params->{class};
    my $label   = $params->{label};
    my $uid     = $params->{uid};

    # Initialize result
    my @result;

    # Determine classname from keyword
    $class = CAE::DYNA::Helpers::modulename($keyword)
        if defined $keyword and not defined $class;

    # Determine label from classname
    $label = CAE::DYNA::Helpers::uidlabel($class)
        if defined $class and not defined $label;

    # Check if label is defined
    confess "Failed to determine UID label" unless defined $label;

    # If there is no matching label in inventory hash
    return @result unless exists $self->{inventory}{$label};

    # Fetch value
    my $value = $self->{inventory}{$label};

    #
    if (defined reftype($value))
    {
        #
        if (reftype($value) eq 'HASH')
        {
            # Check if UID defined
            if (defined $uid)
            {
                #
                if (not defined reftype($uid))
                {
                    # UID is defined as scalar
                    $uid = [ $uid ];
                }
                elsif (reftype($uid) eq 'ARRAY')
                {
                    # UID is array reference
                }
                else
                {
                    # UID is hash reference (not implemented yet)
                    $uid = [ values %{$uid} ];
                }
            }
            else
            {
                # No UID set
                $uid = [ keys %{$value} ];
            }

            # Loop over all requested keys
            for my $key (@{$uid})
            {
                # Skip unless key exists
                next unless exists $value->{$key};

                # Skip unless class matches search class
                next if defined $class and
                                $class ne blessed($value->{$key});

                # Add object to results array
                push @result, $value->{$key};
            }
        }
        elsif (reftype($value) eq 'ARRAY')
        {
            # not implemented yet
        }
        else
        {
            # not implemented yet
        }
    }
    else
    {
        # not implemented yet
    }

    # Return context-based result
    return wantarray ? @result : (scalar @result == 1) ? $result[0] : undef;
}


#-------------------------------------------------------------------------------
#     S T R I N G I F Y
#-------------------------------------------------------------------------------

=item stringfy

...

=cut

sub stringify
{
    # Fetch parameters
    my $self = shift @_;

    #
    my $result = "*KEYWORD\n";

    # Separator line
    my $sepline = "\$\n\$" .  ('-' x 79) . "\n\$\n";

    # Print keyfile header
    if (defined $self->header)
    {
        $result .= $sepline;
        for my $line (split /\n/, $self->header)
        {
            chomp($line);
            $line =~ s/\$#?//g;
            $result .= sprintf("\$ %s\n",$line);
        }
        $result =~ s/\h+\n/\n/g;
    }

    # Loop over all keys of inventory hash
    for my $topclass (sort { $a cmp $b } keys %{$self->{inventory}})
    {
        #
        my $value = $self->{inventory}{$topclass};

        #
        if (defined reftype($value))
        {
            #
            if (reftype($value) eq 'HASH')
            {
                # Check type of keys in hash
                my @keys = keys %{$value};

                if (all { m/^$RE{num}{int}$/i } @keys)
                {
                    # Sort numerically
                    @keys = sort { $a <=> $b } @keys;
                }
                else
                {
                    # Sort alphabetically
                    @keys = sort @keys;
                }

                # Blank keyword and comment lines
                my $blank = 0;

                # Reference to last object
                my $last_object;

                # Loop over all objects
                for my $key (@keys)
                {
                    #
                    my $object = $value->{$key};

                    # Initialize string
                    my $str = '' . $object;

                    #
                    if ($blank and $object->collapsable
                               and defined $last_object
                               and $object->name eq $last_object->name)
                    {
                        # Remove keyword
                        $str =~ s/^\*[\w\_]+\n//;

                        # Remove comments
                        $str =~ s/\$.*\n//g;
                    }
                    else
                    {
                        # Add leading blank line
                        $str = $sepline . $str;

                        # Blank after first object
                        $blank = 1;
                    }

                    # Save object to track TITLE option changes
                    $last_object = $object;

                    # Add object string to result string
                    $result .= $str;
                }
            }
            elsif (reftype($value) eq 'ARRAY')
            {
                # not implemented yet
            }
            else
            {
                # not implemented yet
            }
        }
        else
        {
            # not implemented yet
        }
    }

    #
    $result .= $sepline . "*END\n";

    #
    return $result;
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

no Moose; __PACKAGE__->meta->make_immutable;

1;
