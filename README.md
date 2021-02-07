# cae-dyna-perl

Perl bundle `CAE::DYNA` - Modules for handling LS-DYNA keyword files

## Synopsis

```perl
# Include module
use CAE::DYNA::Keyfile;
```

## Requires

- [File::Slurp](https://metacpan.org/pod/File::Slurp)
- [Math::Vector::Real](https://metacpan.org/pod/Math::Vector::Real)
- [Module::Find](https://metacpan.org/pod/Module::Find)
- [Moose](https://metacpan.org/pod/Moose)
- [Readonly](https://metacpan.org/pod/Readonly)
- [Regexp::Common](https://metacpan.org/pod/Regexp::Common)
- [Text::Trim](https://metacpan.org/pod/Text::Trim)
- [Try::Tiny](https://metacpan.org/pod/Try::Tiny)

## Installation

To install this module, run the following commands:

```bash
$ perl Makefile.PL
$ make
$ make test
$ make install
```

In order to consider an alternate installation location for scripts,
manpages and libraries, use the `PREFIX` value as a parameter on the
command line:

```bash
$ perl Makefile.PL PREFIX=~/testing
```

## Description

### Export

Nothing.

## Methods

### Constructor

- **new**

  ...

  - **filepath** => _value_

    ...

  - **inventory** => _value_

    ...

  - **header** => _value_

    ...

### Object Methods

Here is a list of object methos available.  Object methods are applied to
the object in question, in contrast to class methods which are applied to
a class.

- **clone**

    ...

- **load**

    ...

- **save**

    ...

- **include** ( _filename_ )

    ...

- **add** ( _array_ )

    ...

- **fetch** ( _hashref_ )

    ...

    - **keyword** => _value_

    - **class** => _value_

    - **label** => _value_

    - **uid** => _value_


- **stringfy**

    ...

## Subroutines

## Bugs and Limitations

## Copyright and License

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
