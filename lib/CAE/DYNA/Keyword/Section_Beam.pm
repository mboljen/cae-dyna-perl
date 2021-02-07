# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Mo 2020-04-06 13:20:52 CEST
# Last Modified:  Do 2020-04-23 18:21:55 CEST
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword::Section_Beam;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;

extends 'CAE::DYNA::Keyword';

has '+name' => (
    default => '*SECTION_BEAM',
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

has 'qr_irid' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 2.0,
);

has 'cst' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

has 'scoor' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);
has 'nsm' => (
    is      => 'rw',
    isa     => 'Maybe[Num]',
    default => 0.0,
);

# types 1, 11
has 'ts1'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'ts2'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'tt1'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'tt2'     => ( is => 'rw', isa => 'Maybe[Num]' );

# types 1 and 11
has 'nsloc'   => ( is => 'rw', isa => 'Maybe[Num]' );
has 'ntloc'   => ( is => 'rw', isa => 'Maybe[Num]' );

# types 2, 3, and 12 only and STYPE is SECTION
has 'stype'   => ( is => 'rw', isa => 'Maybe[Str]' );
has 'd1'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'd2'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'd3'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'd4'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'd5'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'd6'      => ( is => 'rw', isa => 'Maybe[Num]' );

# types 2, 12, and 13 only and STYPE is not SECTION
has 'a'       => ( is => 'rw', isa => 'Maybe[Num]' );
has 'iss'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'itt'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'j'       => ( is => 'rw', isa => 'Maybe[Num]' );
has 'sa'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'ist'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'itorm'   => ( is => 'rw', isa => 'Maybe[Num]' );

# type 12 only and STYPE is not SECTION
has 'ys'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'zs'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'iyr'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'izr'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'irr'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'iw'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'iwr'     => ( is => 'rw', isa => 'Maybe[Num]' );

# type 3 only
has 'rampt'   => ( is => 'rw' );
has 'stress'  => ( is => 'rw' );

# type 6 and material type is not 146
has 'vol'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'iner'    => ( is => 'rw', isa => 'Maybe[Num]' );
has 'cid'     => ( is => 'rw', isa => 'Maybe[Num]' );
has 'ca'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'offset'  => ( is => 'rw', isa => 'Maybe[Num]' );
has 'rrcon'   => ( is => 'rw', isa => 'Maybe[Num]' );
has 'srcon'   => ( is => 'rw', isa => 'Maybe[Num]' );
has 'trcon'   => ( is => 'rw', isa => 'Maybe[Num]' );

# type 6 and material type is 146
has 'dofn1'   => ( is => 'rw', isa => 'Maybe[Num]' );
has 'dofn2'   => ( is => 'rw', isa => 'Maybe[Num]' );

# type 9
has 'print'   => ( is => 'rw', isa => 'Maybe[Num]' );
has 'itoff'   => ( is => 'rw', isa => 'Maybe[Num]' );

# type 14
has 'pr'      => ( is => 'rw', isa => 'Maybe[Num]' );
has 'iovpr'   => ( is => 'rw', isa => 'Maybe[Num]' );
has 'iprstr'  => ( is => 'rw', isa => 'Maybe[Num]' );



=head1 NAME

CAE::DYNA::Keyword::Section_Beam - Module for handling LS-DYNA keyword

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword::Section_Beam;

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
    #my ($buffer_min, $buffer_max) = (0, 2);

    #
    #$buffer_max++ if $keyword =~ m/\_TITLE$/i;

    #
    my @result;

    #while (@{$buffer})
    #{
        # Fetch
        #my @card = splice @{$buffer}, 0, $buffer_max;

        #my ($title) =
        #    ($keyword =~ m/\_TITLE$/i) ?
        #        CAE::DYNA::Helpers::unpackundef('A80', shift @card) : undef;

        #
        #my ($secid, $elform, $shrf, $nip, $propt, $qr_irid, $icomp, $setyp) =
        #    CAE::DYNA::Helpers::unpackundef('A10' x 8, $card[0]);

        #
        #my ($t1, $t2, $t3, $t4, $nloc, $marea, $idof, $edgset) =
        #    CAE::DYNA::Helpers::unpackundef('A10' x 8, $card[1]);

        #
        #my $new = __PACKAGE__->new({
        #    name    => $keyword,
        #    host    => $host,
        #    title   => $title,
        #    secid   => $secid,
        #    elform  => $elform,
        #    shrf    => $shrf,
        #    nip     => $nip,
        #    propt   => $propt,
        #    qr_irid => $qr_irid,
        #    icomp   => $icomp,
        #    setyp   => $setyp,
        #    t1      => $t1,
        #    t2      => $t2,
        #    t3      => $t3,
        #    t4      => $t4,
        #    nloc    => $nloc,
        #    marea   => $marea,
        #    idof    => $idof,
        #    edgset  => $edgset,
        #});

        # Add new object to results array
        #push @result, $new;
    #}

    # Return results array
    return @result;

}


#-------------------------------------------------------------------------------
#     S T R I N G I F Y
#-------------------------------------------------------------------------------

=item stringify

Prints the beam section in keyword format.

=cut

sub stringify
{
    #
    my ($self) = @_;

    #
    my $str = $self->name . "\n";

    #
    if (defined $self->title =~ m/\_TITLE$/i)
    {
        $str .= sprintf("\$#%80s\n", qw(title));
        $str .= sprintf("%-80s", $self->title);
    }

    #
    #$str .=
    #    sprintf("\$#%8s" . ("%10s" x 7) . "\n",
    #        qw(secid elform shrf nip propt qr/irid icomp setyp));

    #
    #$str .=
    #    sprintf(("%10s" x 8) . "\n",
    #        $self->secid,
    #        $self->elform,
    #        $self->shrf,
    #        $self->nip,
    #        $self->propt,
    #        $self->qr_irid,
    #        $self->icomp,
    #        $self->setyp);

    #
    #$str .=
    #    sprintf("\$#%6s" . ("%8s" x 9) . "\n",
    #        qw( eid pid n1 n2 n3 n4 n5 n6 n7 n8 ) );

    #
    #$str .=
    #    sprintf("%8s" x 10 . "\n",
    #        $self->eid,
    #        $self->pid,
    #        $self->n1,
    #        $self->n2,
    #        $self->n3,
    #        $self->n4,
    #        defined $self->n5 ? $self->n5 : '',
    #        defined $self->n6 ? $self->n6 : '',
    #        defined $self->n7 ? $self->n7 : '',
    #        defined $self->n8 ? $self->n8 : '' );

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
