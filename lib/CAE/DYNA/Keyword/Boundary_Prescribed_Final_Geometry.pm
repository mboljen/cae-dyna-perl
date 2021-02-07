# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Do 2020-04-16 20:19:46 CEST
# Last Modified:  Do 2020-04-23 18:20:53 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Boundary_Prescribed_Final_Geometry;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;
use Regexp::Common qw(number);

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*BOUNDARY_PRESCRIBED_FINAL_GEOMETRY',
);

has 'bpfgid' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has 'lcidf' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'deathd' => (
    is  => 'rw',
    isa => 'Maybe[Num]',
);

has 'nodes' => (
    is      => 'rw',
    isa     => 'CAE::DYNA::Keyword::Boundary_Prescribed_Final_Geometry::Nodes',
    default => sub {
        CAE::DYNA::Keyword::Boundary_Prescribed_Final_Geometry::Nodes->new();
    },
);


#-------------------------------------------------------------------------------
#     S U B - C L A S S E S
#-------------------------------------------------------------------------------

{
    package CAE::DYNA::Keyword::Boundary_Prescribed_Final_Geometry::Nodes;
    use Moose;

    has '_nodes' => (
        is      => 'ro',
        isa     => 'HashRef[CAE::DYNA::Keyword::' .
                           'Boundary_Prescribed_Final_Geometry::Node]',
        traits  => [ 'Hash' ],
        default => sub { {} },
        handles => {
            delete => 'delete',
            keys   => 'keys',
            set    => 'set',
            get    => 'get',
        },
    );

    sub save
    {
        #
        my ($self, $params) = @_;

        #
        my $nid   = $params->{nid};
        my $x     = $params->{x};
        my $y     = $params->{y};
        my $z     = $params->{z};
        my $lcid  = $params->{lcid};
        my $death = $params->{death};

        #
        my $node = CAE::DYNA::Keyword::Boundary_Prescribed_Final_Geometry::Node->new({
            nid   => $nid,
            x     => $x,
            y     => $y,
            z     => $z,
            lcid  => $lcid,
            death => $death
        });

        # Add node object to nodes hash
        $self->set($nid => $node);
    }


    package CAE::DYNA::Keyword::Boundary_Prescribed_Final_Geometry::Node;

    use Moose;

    has 'nid'   => (
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

    has 'lcid' => (
        is  => 'rw',
        isa => 'Maybe[PosInt]',
    );

    has 'death' => (
        is  => 'rw',
        isa => 'Maybe[Num]',
    );
}


=head1 NAME

CAE::DYNA::Keyword::Boundary_Prescribed_Final_Geometry - Module for handling LS-DYNA keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Boundary_Prescribed_Final_Geometry;

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
    return $self->bpfgid;
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

    #
    my ($buffer_min, $buffer_max) = (0, scalar @{$buffer});

    #
    my @result;

    # Fetch cards from buffer
    my @card = @{$buffer};

    # Get data of first card
    my ($bpfgid, $lcidf, $deathd) =
        CAE::DYNA::Helpers::unpackundef('A10' x 3, $card[0]);

    #
    my $new = __PACKAGE__->new({
        name   => $keyword,
        host   => $host,
        bpfgid => $bpfgid,
        lcidf  => $lcidf,
        deathd => $deathd,
    });

    # Loop over complete stack
    for my $i (1 .. $#card)
    {
        # Fetch abscissa and ordinate value
        my ($nid, $x, $y, $z, $lcid, $death) =
            CAE::DYNA::Helpers::unpackundef('A8A16A16A16A8A16', $card[$i]);

        #
        $new->nodes->save({ nid  => $nid,
                            x     => $x,
                            y     => $y,
                            z     => $z,
                            lcid  => $lcid,
                            death => $death });
    }

    # Add new object to results array
    push @result, $new;

    #
    return @result;
}


#-------------------------------------------------------------------------------
#     S T R I N G F Y
#-------------------------------------------------------------------------------

=item stringify

Prints the boundary constraint in keyword format.

=cut

sub stringify
{
    #
    my ($self) = @_;

    #
    my $str = $self->name . "\n";

    #
    $str .= sprintf("\$#%8s%10s%10s\n", qw( bpfgid lcidf deathd ));

    #
    $str .=
        sprintf(("%10s" x 3) . "\n",
            $self->bpfgid,
            defined $self->lcidf  ? $self->lcidf  : '',
            defined $self->deathd ? $self->deathd : '');

    #
    $str .=
        sprintf("\$#%6s%16s%16s%16s%8s%16s\n",
            qw( nid x y z lcid death ));

    #
    for my $nid (sort { $a <=> $b } $self->nodes->keys)
    {
        #
        my $node = $self->nodes->get($nid);
        #
        $str .=
            sprintf("%8s%16s%16s%16s%8s%16s\n",
                $nid,
                $node->x,
                $node->y,
                $node->z,
                defined $node->lcid  ? $node->lcid  : '',
                defined $node->death ? $node->death : ''
            );
    }

    # Trim horizontal whitespace
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
