# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Mo 2020-04-06 13:20:52 CEST
# Last Modified:  Mo 2020-05-11 10:36:28 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Mat_Null;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*MAT_NULL',
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

has 'pc' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'mu' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'terod' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'cerod' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'ym' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'pr' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);


=head1 NAME

CAE::DYNA::Keyword::Mat_Null - Module for handling LS-DYNA keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Mat_Null;

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
    my ($buffer_min, $buffer_max) = ( 0, 1 );

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
        my ($mid, $ro, $pc, $mu, $terod, $cerod, $ym, $pr) =
            CAE::DYNA::Helpers::unpackundef('A10' x 8, $card[0]);

        #
        my $new = __PACKAGE__->new({
            name  => $keyword,
            host  => $host,
            mid   => $mid,
            ro    => $ro,
            pc    => $pc,
            terod => $terod,
            cerod => $cerod,
            ym    => $ym,
            pr    => $pr,
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
        sprintf("\$#%8s" . ("%10s" x 7) . "\n",
            qw( mid ro pc mu terod cerod ym pr ));

    #
    $str .=
        sprintf("%10s" x 8 . "\n",
            $self->mid,
            $self->ro,
            defined $self->pc    ? $self->pc    : '',
            defined $self->mu    ? $self->mu    : '',
            defined $self->terod ? $self->terod : '',
            defined $self->cerod ? $self->cerod : '',
            defined $self->ym    ? $self->ym    : '',
            defined $self->pr    ? $self->pr    : '' );

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
