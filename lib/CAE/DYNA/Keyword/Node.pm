# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Fr 2020-01-31 16:39:11 CET
# Last Modified:  Do 2020-04-23 18:21:37 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Node;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;
use Math::Vector::Real;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*NODE',
);

has '+collapsable' => (
    default => 1,
);

has 'nid' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has 'x' => (
    is  => 'rw',
    isa => 'Num',
);

has 'y' => (
    is  => 'rw',
    isa => 'Num',
);

has 'z' => (
    is  => 'rw',
    isa => 'Num',
);

has 'tc' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'rc' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);


=head1 NAME

CAE::DYNA::Keyword::Node - Module for handling LS-DYNA keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Node;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=cut

#-------------------------------------------------------------------------------
#     U I D
#-------------------------------------------------------------------------------

=item uid

...

=cut

sub uid
{
    my ($self) = @_;
    return $self->nid;
}


#-------------------------------------------------------------------------------
#     R E A D
#-------------------------------------------------------------------------------

=item read

...

=cut

#
sub read
{
    #
    my ($class, $params) = @_;

    #
    confess "Subroutine 'read' cannot be invoked as a method"
        if defined blessed($class);

    #
    my $host    = $params->{host};
    my $keyword = $params->{keyword};
    my $buffer  = $params->{buffer};

    # Check buffer boundaries
    my ($buffer_min, $buffer_max) = ( 0, 1 );
    #
    #
    #

    # Result container
    my @result;

    # Loop over array reference
    while (@{$buffer})
    {
        # Fetch first buffer from stack
        my @card = splice @{$buffer}, 0, $buffer_max;

        # Extract values
        my ($nid, $x, $y, $z, $tc, $rc) =
            CAE::DYNA::Helpers::unpackundef('A8A16A16A16A8A8', $card[0]);

        # Initialize new node
        my $new = __PACKAGE__->new({
            name => $keyword,
            host => $host,
            nid  => $nid,
            x    => $x,
            y    => $y,
            z    => $z,
            tc   => $tc,
            rc   => $rc,
        });

        # Add new object to results array
        push @result, $new;
    }

    # Reurn results array
    return @result;
}


#-------------------------------------------------------------------------------
#     S T R I N G I F Y
#-------------------------------------------------------------------------------

=item stringify

Prints the node in keyword format.

=cut

sub stringify
{
    #
    my ($self) = @_;

    #
    my $str = $self->name . "\n";

    #
    $str .=
        sprintf("\$#%6s%16s%16s%16s%8s%8s\n",
            qw( nid x y z tc rc ));

    #
    $str .=
        sprintf("%8d%16.5f%16.5f%16.5f%8s%8s\n",
            $self->nid,
            $self->x,
            $self->y,
            $self->z,
            defined $self->tc ? $self->tc : '',
            defined $self->rc ? $self->rc : '' );

    # Trim horizontal whitespace
    $str =~ s/\h+\n/\n/g;

    # Returns result
    return $str;
}


#-------------------------------------------------------------------------------
#     V E C T O R
#-------------------------------------------------------------------------------

=item vector(I<args>)

Returns a vector pointing to the node.

=cut

sub vector
{
    #
    my ($self) = @_;
    return V( $self->x, $self->y, $self->z );
}

=back

=head1 DEPENDENCIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Matthias Boljen (L<matthias.boljen@emi.fraunhofer.de>)

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

__PACKAGE__->meta->make_immutable;

1;
