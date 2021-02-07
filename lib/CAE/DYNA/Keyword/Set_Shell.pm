# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Mo 2020-04-06 13:20:52 CEST
# Last Modified:  Do 2020-04-23 18:22:11 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Set_Shell;

use Moose;
use namespace::autoclean;

use Data::Dumper;
use CAE::DYNA::Helpers;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*SET_SHELL',
);

has '+title_ok' => (
    default => 1,
);

has 'sid' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has 'da1' => (
    is  => 'rw',
    isa => 'Maybe[Num]',
);

has 'da2' => (
    is  => 'rw',
    isa => 'Maybe[Num]',
);

has 'da3' => (
    is  => 'rw',
    isa => 'Maybe[Num]',
);

has 'da4' => (
    is  => 'rw',
    isa => 'Maybe[Num]',
);

has 'eid' => (
    is      => 'rw',
    isa     => 'CAE::DYNA::Keyword::Set_Shell::Elements',
    default => sub {
        CAE::DYNA::Keyword::Set_Shell::Elements->new();
    },
);


#-------------------------------------------------------------------------------
#     S U B - C L A S S E S
#-------------------------------------------------------------------------------

{
    package CAE::DYNA::Keyword::Set_Shell::Elements;
    use Moose;

    has '_eid' => (
        is      => 'ro',
        isa     => 'ArrayRef[Int]',
        traits  => [ 'Array' ],
        default => sub { [] },
        handles => {
            count         => 'count',
            is_empty      => 'is_empty',
            all           => 'elements',
            get           => 'get',
            set           => 'set',
            pop           => 'pop',
            push          => 'push',
            shift         => 'shift',
            unshift       => 'unshift',
            sort_in_place => 'sort_in_place',
        },
    );
}


=head1 NAME

CAE::DYNA::Keyword::Set_Shell - Module for handling keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Set_Shell;

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
    return $self->sid;
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
    my ($buffer_min, $buffer_max) = ( 0, scalar @{$buffer} );

    #
    my @result;

    #
    my @card = @{$buffer};

    #
    my ($title) =
        ($keyword =~ m/\_TITLE$/i) ?
            CAE::DYNA::Helpers::unpackundef('A80', shift @card) : undef;

    #
    my ($sid, $da1, $da2, $da3, $da4) =
        CAE::DYNA::Helpers::unpackundef('A10' x 5, $card[0]);

    #
    my $new = __PACKAGE__->new({
        name  => $keyword,
        host  => $host,
        sid   => $sid,
        da1   => $da1,
        da2   => $da2,
        da3   => $da3,
        da4   => $da4,
    });

    # Set title
    $new->title($title);

    #
    if ($keyword =~ m/^\*SET\_SHELL(?:\_LIST)?/i)
    {
        # Loop over all existing cards
        for my $i (1 .. $#card)
        {
            my @eid = CAE::DYNA::Helpers::unpackundef('A10' x 8, $card[$i]);
            map { $new->eid->push($_) if defined and $_ > 0 } @eid;
        }
    }
    else
    {
        # not implemented yet
    }

    #
    push @result, $new;

    # Return results array
    return @result;
}


#-------------------------------------------------------------------------------
#     S T R I N G I F Y
#-------------------------------------------------------------------------------

=item stringify

Prints the shell set in keyword format.

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
        sprintf("\$#%8s" . ("%10s" x 4) . "\n", qw( sid da1 da2 da3 da4 ));

    #
    $str .=
        sprintf(("%10s" x 5) . "\n",
            $self->sid,
            defined $self->da1 ? $self->da1 : '',
            defined $self->da2 ? $self->da2 : '',
            defined $self->da3 ? $self->da3 : '',
            defined $self->da4 ? $self->da4 : '' );

    #
    if ($self->name =~ m/^\*SET\_SHELL(?:\_LIST)?/i)
    {
        #
        $str .=
            sprintf("\$#%8s". ("%10s" x 7) . "\n",
                qw( eid1 eid2 eid3 eid4 eid5 eid6 eid7 eid8 ));

        #
        my $col = 1;

        #
        for my $eid ($self->eid->all)
        {
            $str .= sprintf("%10s", $eid);
            $str .= "\n" if $col++ % 8 == 0 or $eid == $self->eid->get(-1);
        }
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
