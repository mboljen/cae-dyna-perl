# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Mo 2020-04-06 13:20:52 CEST
# Last Modified:  Sa 2020-04-25 21:26:25 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Mat_Plastic_Kinematic;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*MAT_PLASTIC_KINEMATIC',
);

has '+title_ok' => (
    default => 1
);

has 'mid' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'ro' => (
    is  => 'rw',
    isa => 'Num',
);

has 'e' => (
    is  => 'rw',
    isa => 'Num',
);

has 'pr' => (
    is  => 'rw',
    isa => 'Num',
);

has 'sigy' => (
    is  => 'rw',
    isa => 'Num',
);

has 'etan' => (
    is  => 'rw',
    isa => 'Maybe[Num]',
    default => 0.0,
);

has 'beta' => (
    is => 'rw',
    isa => 'Maybe[Num]',
    default => 0.0,
);

has 'src' => (
    is => 'rw',
    isa => 'Maybe[Num]',
    default => 0.0,
);

has 'srp' => (
    is => 'rw',
    isa => 'Maybe[Num]',
    default => 0.0,
);

has 'fs' => (
    is => 'rw',
    isa => 'Maybe[Num]',
    default => 1E20,
);

has 'vp' => (
    is => 'rw',
    isa => 'Maybe[Num]',
    default => 0.0,
);


=head1 NAME

CAE::DYNA::Keyword::Mat_Plastic_Kinematic - Module for handling LS-DYNA keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Mat_Plastic_Kinematic;

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
    return $self->mid;
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
    $buffer_max++ if $keyword =~ m/\_TITLE$/i;

    #
    my @result;

    while (@{$buffer})
    {
        # Fetch buffer
        my @card = splice @{$buffer}, 0, $buffer_max;

        # Optional title card
        my ($title) =
            ($keyword =~ m/\_TITLE$/i) ?
                CAE::DYNA::Helpers::unpackundef('A80', shift @card) : undef;

        # Card 1
        my ($mid, $ro, $e, $pr, $sigy, $etan, $beta) =
            CAE::DYNA::Helpers::unpackundef('A10' x 7, $card[0]);

        # Card 2
        my ($src, $srp, $fs, $vp) =
            CAE::DYNA::Helpers::unpackundef('A10' x 4, $card[0]);

        #
        my $new = __PACKAGE__->new({
            name  => $keyword,
            host  => $host,
            mid   => $mid,
            ro    => $ro,
            e     => $e,
            pr    => $pr,
            sigy  => $sigy,
            etan  => $etan,
            beta  => $beta,
            src   => $src,
            srp   => $srp,
            fs    => $fs,
            vp    => $vp,
        });

        # Set title
        $new->title($title);

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

Prints the material in keyword format.

=cut

sub stringify
{
    #
    my ($self) = @_;

    #
    my $str = $self->name . "\n";

    #
    if (defined $self->title)
    {
        $str .= sprintf("\$#%78s\n", qw(title));
        $str .= sprintf("%-80s\n", $self->title);
    }

    #
    $str .=
        sprintf("\$#%8s" . ("%10s" x 6) . "\n",
            qw( mid ro e pr sigy etan beta ));

    #
    $str .=
        sprintf("%10s" x 7 . "\n",
            $self->mid,
            $self->ro,
            $self->e,
            $self->pr,
            $self->sigy,
            defined $self->etan ? $self->etan : '',
            defined $self->beta ? $self->beta : '' );

    # Card 2
    $str .= sprintf("\$#%8s" . ("%10s" x 3) . "\n", qw( src srp fs vp ));

    #
    $str .=
        sprintf("%10s" x 4 . "\n",
            defined $self->src ? $self->src : '',
            defined $self->srp ? $self->srp : '',
            defined $self->fs  ? $self->fs  : '',
            defined $self->vp  ? $self->vp  : '' );

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
