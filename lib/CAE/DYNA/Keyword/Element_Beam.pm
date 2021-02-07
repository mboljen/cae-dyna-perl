# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Mo 2020-04-06 13:20:52 CEST
# Last Modified:  Do 2020-04-23 18:21:15 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Element_Beam;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*ELEMENT_BEAM',
);

has '+collapsable' => (
    default => 1,
);

has 'eid' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has 'pid' => (
    is  => 'rw',
    isa => 'Int',
);

has 'n1' => (
    is  => 'rw',
    isa => 'Int',
);

has 'n2' => (
    is  => 'rw',
    isa => 'Int',
);

has 'n3' => (
    is  => 'rw',
    isa => 'Maybe[Int]',
);

has 'rt1' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'rr1' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'rt2' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'rr2' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'local' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

=head1 NAME

CAE::DYNA::Keyword::Element::Beam - Module for handling LS-DYNA keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Element_Beam;

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
    return $self->eid;
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
    my ($buffer_min, $buffer_max) = (0, 1);
    #
    #
    #

    #
    my @result;

    while (@{$buffer})
    {
        # Fetch
        my @card = splice @{$buffer}, 0, $buffer_max;

        #
        my ($eid, $pid, $n1, $n2, $n3, $rt1, $rr1, $rt2, $rr2, $local) =
            CAE::DYNA::Helpers::unpackundef('A8' x 10, $card[0]);

        #
        my $new = __PACKAGE__->new({
            name  => $keyword,
            host  => $host,
            eid   => $eid,
            pid   => $pid,
            n1    => $n1,
            n2    => $n2,
            n3    => $n3,
            rt1   => $rt1,
            rr1   => $rr1,
            rt2   => $rt2,
            rr2   => $rr2,
            local => $local,
        });

        # Add new object to results array
        push @result, $new;
    }

    # Return results array
    return @result;

}


#-------------------------------------------------------------------------------
#     S T R I N G I F Y
#-------------------------------------------------------------------------------

=item stringify

Prints the beam element in keyword format.

=cut

sub stringify
{
    #
    my ($self) = @_;

    #
    my $str = $self->name . "\n";

    #
    $str .=
        sprintf("\$#%6s" . ("%8s" x 9) . "\n",
            qw( eid pid n1 n2 n3 rt1 rr1 rt2 rr2 local ));

    #
    $str .=
        sprintf("%8s" x 10 . "\n",
            $self->eid,
            $self->pid,
            $self->n1,
            $self->n2,
            defined $self->n3    ? $self->n3    : '',
            defined $self->rt1   ? $self->rt1   : '',
            defined $self->rr1   ? $self->rr1   : '',
            defined $self->rt2   ? $self->rt2   : '',
            defined $self->rr2   ? $self->rr2   : '',
            defined $self->local ? $self->local : '' );

    # Remove trailing spaces and tabulators, but no newlines
    $str =~ s/\h+\n/\n/g;

    # Return result
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
