use strict;
use warnings;
use Test::More tests => 3;
use Test::Exception;

use FindBin;
use lib "$FindBin::Bin/lib";
use ErrValidate;

use MooseX::Method::Signatures;

my $o = bless {} => 'Foo';

my $meth = method ($, $, $foo, $, $bar, $) {
    return $foo . $bar;
};
isa_ok($meth, 'Moose::Meta::Method');

mxms_dies_ok(sub {
    $meth->($o, 1, 2, 3, 4, 5);
}, 'main::__ANON__');

lives_and(sub {
    is($meth->($o, 1, 2, 3, 4, 5, 6), 35);
});

1;
