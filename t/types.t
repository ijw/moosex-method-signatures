use strict;
use warnings;
use Test::More tests => 4;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/lib";
use ErrValidate;

{
    package MyTypes;
    use MooseX::Types::Moose qw/Str/;
    use Moose::Util::TypeConstraints;
    use MooseX::Types -declare => [qw/CustomType/];

    BEGIN {
        subtype CustomType,
            as Str,
            where { length($_) == 2 };
    }
}

{
    package TestClass;
    use MooseX::Method::Signatures;
    BEGIN { MyTypes->import('CustomType') };
    use MooseX::Types::Moose qw/ArrayRef/;
    use namespace::clean;

    method foo (CustomType $bar) { }

    method bar (ArrayRef[CustomType] $baz) { }
}

my $o = bless {} => 'TestClass';

lives_ok(sub { $o->foo('42') });
mxms_dies_ok(sub { $o->foo('bar') }, 'TestClass::foo');

lives_ok(sub { $o->bar(['42', '23']) });
mxms_dies_ok(sub { $o->bar(['foo', 'bar']) }, 'TestClass::bar');
