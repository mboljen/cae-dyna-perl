# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Do 2020-04-16 20:19:46 CEST
# Last Modified:  Do 2020-04-23 18:21:02 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Define_Curve;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*DEFINE_CURVE',
);

has '+title_ok' => (
    default => 1,
);

has 'lcid' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has 'sidr' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'sfa' => (
    is      => 'rw',
    isa     => 'Num',
    default => 1.0,
);

has 'sfo' => (
    is      => 'rw',
    isa     => 'Num',
    default => 1.0,
);

has 'offa' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0.0,
);

has 'offo' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0.0,
);

has 'dattyp' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'lcint' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'points' => (
    is      => 'rw',
    isa     => 'CAE::DYNA::Keyword::Define_Curve::Points',
    default => sub {
        CAE::DYNA::Keyword::Define_Curve::Points->new();
    },
);


#-------------------------------------------------------------------------------
#     S U B - C L A S S E S
#-------------------------------------------------------------------------------

{
    package CAE::DYNA::Keyword::Define_Curve::Points;

    use Moose;

    has '_points' => (
        is      => 'ro',
        isa     => 'ArrayRef[CAE::DYNA::Keyword::Define_Curve::Point]',
        traits  => [ 'Array' ],
        default => sub { [] },
        handles => {
            count    => 'count',
            is_empty => 'is_empty',
            all      => 'elements',
            get      => 'get',
            pop      => 'pop',
            push     => 'push',
            shift    => 'shift',
            unshift  => 'unshift',
            sort     => 'sort',
        },
    );

    sub save
    {
        #
        my ($self, $params) = @_;

        #
        my $a1 = $params->{a1};
        my $o1 = $params->{o1};

        #
        my $point = CAE::DYNA::Keyword::Define_Curve::Point->new({
            a1 => $a1,
            o1 => $o1,
        });

        # Add point to point list
        $self->push($point);
    }


    package CAE::DYNA::Keyword::Define_Curve::Point;

    use Moose;

    has 'a1' => ( is => 'rw', isa => 'Num', required => 1 );
    has 'o1' => ( is => 'rw', isa => 'Num', required => 1 );

}


=head1 NAME

CAE::DYNA::Keyword::Define_Curve - Module for handling LS-DYNA keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Define_Curve;

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
    return $self->lcid;
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

    #
    my ($title) =
        ($keyword =~ m/\_TITLE$/i) ?
            CAE::DYNA::Helpers::unpackundef('A80', shift @card) : undef;

    # Get data of first card
    my ($lcid, $sidr, $sfa, $sfo, $offa, $offo, $dattyp, $lcint) =
        CAE::DYNA::Helpers::unpackundef('A10' x 8, $card[0]);

    #
    my $new = __PACKAGE__->new({
        name   => $keyword,
        host   => $host,
        lcid   => $lcid,
        sidr   => $sidr,
        sfa    => $sfa,
        sfo    => $sfo,
        offa   => $offa,
        offo   => $offo,
        dattyp => $dattyp,
        lcint  => $lcint,
    });

    # Assign title
    $new->title($title);

    # Loop over complete stack
    for my $i (1 .. $#card)
    {
        # Fetch abscissa and ordinate value
        my ($a1, $o1) =
            CAE::DYNA::Helpers::unpackundef('A20' x 2, $card[$i]);

        # Push data to arrays
        $new->points->save({ a1 => $a1, o1 => $o1 });
    }

    # Add new object to results array
    push @result, $new;

    # Return results
    return @result;
}


#-------------------------------------------------------------------------------
#     S T R I N G I F Y
#-------------------------------------------------------------------------------

=item stringify

Prints the curve in keyword format.

=cut

sub stringify
{
    #
    my ($self) = @_;

    #
    my $str = $self->name . "\n";

    if (defined $self->title)
    {
        $str .= sprintf("\$#%78s\n", qw(title));
        $str .= sprintf("%-80s\n", $self->title);
    }

    #
    $str .=
        sprintf(
            "\$#%8s". ("%10s" x 7) . "\n",
                qw( lcid sidr sfa sfo offa offo dattyp lcint ));

    #
    $str .=
        sprintf(("%10s" x 8) . "\n",
            $self->lcid,
            defined $self->sidr ? $self->sidr : '',
            $self->sfa,
            $self->sfo,
            $self->offa,
            $self->offo,
            defined $self->dattyp ? $self->dattyp : '',
            defined $self->lcint  ? $self->lcint  : '' );

    #
    $str .= sprintf("\$#%18s%20s\n", qw( a1 o1 ));

    #
    for my $pnt ($self->points->all)
    {
        #
        $str .= sprintf(("%20s" x 2) . "\n", $pnt->a1, $pnt->o1 );
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
