# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Mo 2020-04-06 13:20:52 CEST
# Last Modified:  Do 2020-04-23 18:20:43 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Element_Shell;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*ELEMENT_SHELL',
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
    isa => 'Int',
);

has 'n4' => (
    is  => 'rw',
    isa => 'Int',
);

has 'n5' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'n6' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0
);

has 'n7' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'n8' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

=head1 NAME

CAE::DYNA::Keyword::Element_Shell - Module for handling LS-DYNA keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Element_Shell;

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

sub uid {
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
        my ($eid, $pid, $n1, $n2, $n3, $n4, $n5, $n6, $n7, $n8) =
            CAE::DYNA::Helpers::unpackundef('A8' x 10, $card[0]);

        #
        my $new = __PACKAGE__->new({
            name => $keyword,
            host => $host,
            eid  => $eid,
            pid  => $pid,
            n1   => $n1,
            n2   => $n2,
            n3   => $n3,
            n4   => $n4,
            n5   => $n5,
            n6   => $n6,
            n7   => $n7,
            n8   => $n8,
        });

        # Add new object to results array
        push @result, $new;
    }

    # Return results array
    return @result;

}


#-------------------------------------------------------------------------------
#      S T R I N G I F Y
#-------------------------------------------------------------------------------

=item stringify

Prints the shell element in keyword format.

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
            qw( eid pid n1 n2 n3 n4 n5 n6 n7 n8 ));

    #
    $str .=
        sprintf("%8s" x 10 . "\n",
            $self->eid,
            $self->pid,
            $self->n1,
            $self->n2,
            $self->n3,
            $self->n4,
            defined $self->n5 ? $self->n5 : '',
            defined $self->n6 ? $self->n6 : '',
            defined $self->n7 ? $self->n7 : '',
            defined $self->n8 ? $self->n8 : '' );

    # Trim horizontal whitespace
    $str =~ s/\h+\n/\n/g;

    # Return result
    return $str;
}


#-------------------------------------------------------------------------------
#     T Y P E
#-------------------------------------------------------------------------------

=item type

...

=cut

sub type
{
    #
    my $self = shift;

    #
    my $num = {};
    foreach my $key (qw( n1 n2 n3 n4 n5 n6 n7 n8 ))
    {
        my $nid = $self->$key;
        $num->{$nid} = undef if defined $nid and $nid > 0;
    }
    $num = scalar keys %{$num};

    #
    my %lookup = ( 8 => 'quad8', 6 => 'tria6', 4 => 'quad4', 3 => 'tria3' );

    #
    confess "Method 'type' failed to determine element type"
        unless exists $lookup{$num};

    #
    return $lookup{$num};
}


#-------------------------------------------------------------------------------
#     N O R M A L
#-------------------------------------------------------------------------------

=item normal

...

=cut

sub normal
{
    #
    my $self = shift;

    #
    my $ref = $self->host;

    #
    my $n1 = $$ref->fetch({ label => 'NID', uid => $self->n1 });
    my $n2 = $$ref->fetch({ label => 'NID', uid => $self->n2 });
    my $n3 = $$ref->fetch({ label => 'NID', uid => $self->n3 });
    my $n4 = $$ref->fetch({ label => 'NID', uid => $self->n4 });

    # Fake quad for triangular elements
    $n4 = $n3 if not defined $n4 or $self->n4 == 0;

    # Get diagnoals
    my $r31 = $n3->vector - $n1->vector;
    my $r42 = $n4->vector - $n2->vector;

    # Get normal vector
    my $s3 = $r31 x $r42;

    # Return normalized vector
    return $s3->versor;
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
