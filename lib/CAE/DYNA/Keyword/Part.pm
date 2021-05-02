# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Fr 2020-01-31 16:39:11 CET
# Last Modified:  So 2021-05-02 19:14:50 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Part;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;
use Math::Vector::Real;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*PART',
);

has 'heading' => (
    is  => 'rw',
    isa => 'Str',
);

has 'pid' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has 'secid' => (
    is  => 'rw',
    isa => 'Int',
);

has 'mid' => (
    is  => 'rw',
    isa => 'Int',
);

has 'eosid' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'hgid' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'grav' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'adpopt' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'tmid' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

=head1 NAME

CAE::DYNA::Keyword::Part - Module for handling LS-DYNA keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Part;

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
    return $self->pid;
}


#-------------------------------------------------------------------------------
#     R E A D
#-------------------------------------------------------------------------------

=item read

...

=cut

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
    my ($buffer_min, $buffer_max) = ( 0, 2 );
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

        # Extract values from first card
        my ($heading) =
            CAE::DYNA::Helpers::unpackundef('A70', $card[0]);

        # Extract values from second card
        my ($pid, $secid, $mid, $eosid, $hgid, $grav, $adpopt, $tmid) =
            CAE::DYNA::Helpers::unpackundef('A10' x 8, $card[1]);

        # Initialize new node
        my $new = __PACKAGE__->new({
            name    => $keyword,
            host    => $host,
            heading => $heading,
            pid     => $pid,
            secid   => $secid,
            mid     => $mid,
            eosid   => $eosid,
            hgid    => $hgid,
            grav    => $grav,
            adpopt  => $adpopt,
            tmid    => $tmid,
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

Prints the part in keyword format.

=cut

sub stringify
{
    #
    my ($self) = @_;

    #
    my $str = $self->name . "\n";

    #
    $str .= sprintf("\$#%68s\n", qw( heading ) );
    $str .= sprintf("%-70s\n", defined $self->heading ? $self->heading : '' );

    #
    $str .=
        sprintf("\$#%8s" . ( "%10s" x 7 ) . "\n",
            qw(pid secid mid eosid hgid grav adpopt tmid));

    #
    $str .=
        sprintf(("%10s" x 8) . "\n",
            $self->pid,
            $self->secid,
            $self->mid,
            defined $self->eosid  ? $self->eosid  : '',
            defined $self->hgid   ? $self->hgid   : '',
            defined $self->grav   ? $self->grav   : '',
            defined $self->adpopt ? $self->adpopt : '',
            defined $self->tmid   ? $self->tmid   : '' );

    # Trim horizontal whitespace
    $str =~ s/\h+\n/\n/g;

    #
    return $str;
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

__PACKAGE__->meta->make_immutable;

1;
