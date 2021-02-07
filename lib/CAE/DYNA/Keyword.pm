# Copyright 2020 Matthias Boljen. All rights reserved.
#
# Created:        Fr 2020-03-13 00:42:22 CET
# Last Modified:  So 2021-02-07 12:03:40 CET
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package CAE::DYNA::Keyword;

use Moose;
use namespace::autoclean;

use CAE::DYNA::Helpers;
use CAE::DYNA::Keyfile;

# Invoke stringify when being used in string context
use overload '""' => 'stringify';

#
has 'name' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    writer   => '_set_name',
);

has 'host' => (
    is  => 'rw',
    isa => 'ScalarRef[CAE::DYNA::Keyfile]',
);

has 'collapsable' => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

has '_title' => (
    is      => 'ro',
    isa     => 'Maybe[Str]',
    writer  => '_set_title',
);

has 'title_ok' => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

=head1 NAME

CAE::DYNA::Keyword - Base module for handling LS-DYNA keywords

=head1 VERSION

=head1 SYNOPSIS

    use CAE::DYNA::Keyword;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=cut


#-------------------------------------------------------------------------------
#     T T T L E
#-------------------------------------------------------------------------------

=item title

Assigns a title to the current object and appends the suffix _TITLE to the
keyword name where applicable.  This method returns the title if is invoked
without argument.  If the object does provide the _TITLE option, it raises
a warning message.

=cut

sub title
{
    my ($self, $title) = @_;
    if ($self->title_ok)
    {
        # Method invoked as setter (TITLE can be undef!)
        if (scalar @_ > 1)
        {
            # Remove _TITLE from keyword name
            my $name = $self->name;
            $name =~ s/\_TITLE$//i;
            # Append _TITLE to keyword name if defined
            $name .= '_TITLE' if defined $title;
            # Invoke methods to update name and title
            $self->_set_name($name);
            $self->_set_title($title);
        }
        else
        {
            # Method invoked as caller (do not remove!)
        }
    }
    else
    {
        # Issue warning
        warn "*** WARNING\n" .
             "    Keyword object '$self' does not provide _TITLE option\n";
    }

    # Returns result
    return $self->_title;
}

#-------------------------------------------------------------------------------
#     U I D L A B E L
#-------------------------------------------------------------------------------

=item uidlabel

...

=cut

# Wrapper to Helpers subroutine 'topclass'
sub uidlabel
{
    my ($class) = @_;
    $class = blessed($class) if defined blessed($class);
    return CAE::DYNA::Helpers::uidlabel($class);
}


#-------------------------------------------------------------------------------
#     U I D S E T
#-------------------------------------------------------------------------------

=item uidset

...

=cut

#
sub uidset {
    my ($self) = @_;
    return defined $self->uid ? 1 : 0;
}


#-------------------------------------------------------------------------------
#     C L O N E
#-------------------------------------------------------------------------------

=item clone

...

=cut

#
sub clone {
    my ($self, %params) = @_;
    return $self->meta->clone_object($self, %params);
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

#
no Moose; __PACKAGE__->meta->make_immutable;

1;
