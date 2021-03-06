use strict;
use warnings;
use Test::More tests => 18;
use Test::Exception;
use MooseX::Method::Signatures;

use FindBin;
use lib "$FindBin::Bin/lib";
use ErrValidate;

my $o = bless {} => 'Foo';

{
    my @meths = (
        method ($foo, $bar, @rest) {
            return join q{,}, @rest;
        },
        method ($foo, $bar, %rest) {
            return join q{,}, map { $_ => $rest{$_} } keys %rest;
        },
    );

    for my $meth (@meths) {
        mxms_dies_ok(sub { $o->${\$meth->body}() }, 'main::__ANON__');
        mxms_dies_ok(sub { $o->${\$meth->body}('foo') }, 'main::__ANON__');

        lives_and(sub {
            is($o->${\$meth->body}('foo', 'bar'), q{});
        });

        lives_and(sub {
            is($o->${\$meth->body}('foo', 'bar', 1 .. 6), q{1,2,3,4,5,6});
        });
    }
}

{
    my $meth = method (Str $foo, Int $bar, Int @rest) {
        return join q{,}, @rest;
    };

    lives_and(sub {
        is($o->${\$meth->body}('foo', 42), q{});
    });

    lives_and(sub {
        is($o->${\$meth->body}('foo', 42, 23, 13), q{23,13});
    });

    mxms_throws_ok(sub {
        $o->${\$meth->body}('foo', 42, 'moo', 13);
    }, 'main::__ANON__', qr/Validation failed/);
}

{
    my $meth = method (ArrayRef[Int] @foo) {
        return join q{,}, map { @{ $_ } } @foo;
    };

    lives_and(sub {
        is($o->${\$meth->body}([42, 23], [12], [18]), '42,23,12,18');
    });

    mxms_throws_ok(sub {
        $o->${\$meth->body}([42, 23], 12, [18]);
    }, 'main::__ANON__', qr/Validation failed/);
}

{
    my $meth = method (Str $foo, Int @) {};
    lives_ok(sub { $meth->($o, 'foo') });
    lives_ok(sub { $meth->($o, 'foo', 42) });
    lives_ok(sub { $meth->($o, 'foo', 42, 23) });
}

{
    eval 'my $meth = method (:$foo, :@bar) { }';
    like $@, qr/arrays or hashes cannot be named/i;

    eval 'my $meth = method ($foo, @bar, :$baz) { }';
    like $@, qr/named parameters can not be combined with slurpy positionals/i;
}
