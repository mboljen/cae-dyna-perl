# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Fr 2020-01-31 16:39:11 CET
# Last Modified:  Do 2020-04-23 18:22:21 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Title;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*TITLE',
);

has 'title' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

=head1 NAME

CAE::DYNA::Keyword::Title - Module for handling LS-DYNA keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Title;

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
    return 0;
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
        my ($title) =
            CAE::DYNA::Helpers::unpackundef('A80', $card[0]);

        # Initialize new node
        my $new = __PACKAGE__->new({
            name  => $keyword,
            host  => $host,
            title => $title,
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
    $str .= sprintf("\$#%78s\n", qw( title ) );
    $str .= sprintf("%-80s\n", $self->title);

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
