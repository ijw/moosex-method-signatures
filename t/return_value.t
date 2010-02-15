use strict;
use warnings;
use Test::More tests => 4;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/lib";
use ErrValidate;

use MooseX::Method::Signatures;

my $o = bless {} => 'Foo';

{
    my $meth = method (Str $foo, Int $bar) returns (ArrayRef[Str]) {
        return [($foo) x $bar];
    };
    isa_ok($meth, 'Moose::Meta::Method');

    mxms_dies_ok(sub {
        $o->${\$meth->body}('foo')
    }, 'main::__ANON__', qr/(?!return value)/);

    lives_and(sub {
        my $ret = $o->${\$meth->body}('foo', 3);
        is_deeply($ret, [('foo') x 3]);
    });
}

{
    my $meth = method (Str $foo) returns (Int) {
        return 42.5;
    };

    mxms_throws_ok(sub {
        my $x = $o->${\$meth->body}('foo');
    }, 'main::__ANON__', qr/return value/);
}
