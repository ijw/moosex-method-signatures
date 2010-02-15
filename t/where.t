use strict;
use warnings;
use Test::More;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/lib";
use ErrValidate;

{
    package Foo::Bar;
    use Moose;
    has baz => (isa => 'Str', default => 'quux', is => 'ro');

    package Foo;
    use Moose;
    use MooseX::Method::Signatures;

    method m1(Str $arg where { $_ eq 'foo' }) { $arg }
    method m2(Int $arg where { $_ == 1 }) { $arg }
    method m3(Foo::Bar $arg where { $_->baz eq 'quux' }) { $arg->baz }

    method m4(Str :$arg where { $_ eq 'foo' }) { $arg }
    method m5(Int :$arg where { $_ == 1 }) { $arg }
    method m6(Foo::Bar :$arg where { $_->baz eq 'quux' }) { $arg->baz }

    method m7($arg where { 1 }) { }
    method m8(:$arg where { 1 }) { }

    method m9(Str $arg = 'foo' where { $_ eq 'bar' }) { $arg }
}

my $foo = Foo->new;

isa_ok($foo, 'Foo');

lives_and(sub { is $foo->m1('foo'), 'foo' }, 'where positional string type');
mxms_throws_ok(sub { $foo->m1('bar') }, 
	       'Foo::m1',
	       qr/Validation failed/, 'where positional string type');

lives_and(sub { is $foo->m2(1), 1 }, 'where positional int type');
mxms_throws_ok(sub { $foo->m2(0) }, 
	       'Foo::m2',
	       qr/Validation failed/, 'where positional int type');

lives_and(sub { is $foo->m3(Foo::Bar->new), 'quux' }, 'where positional class type');
mxms_throws_ok(sub { $foo->m3(Foo::Bar->new({ baz => 'affe' })) }, 
	       'Foo::m3',
	       qr/Validation failed/, 'where positional class type');

lives_and(sub { is $foo->m4(arg => 'foo'), 'foo' }, 'where named string type');
mxms_throws_ok(sub { $foo->m4(arg => 'bar') }, 
	       'Foo::m4',
	       qr/Validation failed/, 'where named string type');

lives_and(sub { is $foo->m5(arg => 1), 1 }, 'where named int type');
mxms_throws_ok(sub { $foo->m5(arg => 0) }, 
	       'Foo::m5',
	       qr/Validation failed/, 'where named int type');

lives_and(sub { is $foo->m6(arg => Foo::Bar->new), 'quux' }, 'where named class type');
mxms_throws_ok(sub { $foo->m6(arg => Foo::Bar->new({ baz => 'affe' })) }, 
	       'Foo::m6',
	       qr/Validation failed/, 'where named class type');

lives_ok(sub { $foo->m7(1) }, 'where positional');
lives_ok(sub { $foo->m8(arg => 1) }, 'where named');

lives_and(sub { is $foo->m9('bar'), 'bar' }, 'where positional string type with default');
mxms_throws_ok(sub { $foo->m9 },
	       'Foo::m9',
	       qr/Validation failed/, 'where positional string type with default');

done_testing;
