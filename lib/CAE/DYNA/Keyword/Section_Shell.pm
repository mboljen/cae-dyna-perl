# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Mo 2020-04-06 13:20:52 CEST
# Last Modified:  Sa 2020-04-25 21:32:08 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Section_Shell;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*SECTION_SHELL',
);

has '+title_ok' => (
    default => 1,
);

has 'secid' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

has 'elform' => (
    is  => 'rw',
    isa => 'Int',
);

has 'shrf' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 1.0,
);

has 'nip' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 2.
);

has 'propt' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'qr_irid' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'icomp' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 0,
);

has 'setyp' => (
    is      => 'rw',
    isa     => 'Maybe[Int]',
    default => 1,
);

has 't1' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 't2' => (
    is  => 'rw',
    isa => 'Maybe[Num]',
);

has 't3' => (
    is  => 'rw',
    isa => 'Maybe[Num]',
);

has 't4' => (
    is  => 'rw',
    isa => 'Maybe[Num]',
);

has 'nloc' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'marea' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'idof' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'edgset' => (
    is  => 'rw',
    isa => 'Maybe[Int]',
);


=head1 NAME

CAE::DYNA::Keyword::Section_Shell - Module for handling keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Section_Shell;

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
    return $self->secid;
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
        # Fetch
        my @card = splice @{$buffer}, 0, $buffer_max;

        my ($title) =
            ($keyword =~ m/\_TITLE$/i) ?
                CAE::DYNA::Helpers::unpackundef('A80', shift @card) : undef;

        #
        my ($secid, $elform, $shrf, $nip, $propt, $qr_irid, $icomp, $setyp) =
            CAE::DYNA::Helpers::unpackundef('A10' x 8, $card[0]);

        #
        my ($t1, $t2, $t3, $t4, $nloc, $marea, $idof, $edgset) =
            CAE::DYNA::Helpers::unpackundef('A10' x 8, $card[1]);

        #
        my $new = __PACKAGE__->new({
            name    => $keyword,
            host    => $host,
            secid   => $secid,
            elform  => $elform,
            shrf    => $shrf,
            nip     => $nip,
            propt   => $propt,
            qr_irid => $qr_irid,
            icomp   => $icomp,
            setyp   => $setyp,
            t1      => $t1,
            t2      => $t2,
            t3      => $t3,
            t4      => $t4,
            nloc    => $nloc,
            marea   => $marea,
            idof    => $idof,
            edgset  => $edgset,
        });

        #
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

Prints shell section in keyword format.

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

    # First card, labels
    $str .=
        sprintf("\$#%8s" . ("%10s" x 7) . "\n",
            qw( secid elform shrf nip propt qr/irid icomp setyp ));

    # First card, values
    $str .=
        sprintf(("%10s" x 8) . "\n",
            $self->secid,
            $self->elform,
            defined $self->shrf    ? $self->shrf    : '',
            defined $self->nip     ? $self->nip     : '',
            defined $self->propt   ? $self->propt   : '',
            defined $self->qr_irid ? $self->qr_irid : '',
            defined $self->icomp   ? $self->icomp   : '',
            defined $self->setyp   ? $self->setyp   : '');

    # Second card, labels
    $str .=
        sprintf("\$#%8s" . ("%10s" x 7) . "\n",
            qw( t1 t2 t3 t4 nloc marea idof edgset ));

    # Second card, values
    $str .=
        sprintf(("%10s" x 8) . "\n",
            $self->t1,
            defined $self->t2     ? $self->t2     : '',
            defined $self->t3     ? $self->t3     : '',
            defined $self->t4     ? $self->t4     : '',
            defined $self->nloc   ? $self->nloc   : '',
            defined $self->marea  ? $self->marea  : '',
            defined $self->idof   ? $self->idof   : '',
            defined $self->edgset ? $self->edgset : '' );

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
