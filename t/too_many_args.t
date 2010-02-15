use strict;
use warnings;
use Test::More;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/lib";
use ErrValidate;

{
    package Foo;
    use Moose;
    use MooseX::Method::Signatures;

    method foo ($bar) { $bar }
}

my $o = Foo->new;
lives_ok(sub { $o->foo(42) });
mxms_throws_ok(sub { $o->foo(42, 23) }, 'Foo::foo',
	       qr/Validation failed/);

done_testing;
