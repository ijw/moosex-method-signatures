package ErrValidate;

use Test::Exception;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    @EXPORT	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
    mxms_throws_ok mxms_dies_ok
);

sub mxms_throws_ok {
    my ($sub, $testsub_name, $like, $msg) = @_;
    

    # Details of the sub that we expect to be throwing the error
    my ($pkg, $name) = $testsub_name =~ /^(.*)::(.*)$/;
    
    # The error should consist of a proforma part describing the
    # method that objects and the location it was called from, plus a
    # variable part describing the type error.  It should all appear
    # on a single line; we don't guarantee anything for the passed
    # match, but we at least make sure that there's no
    # linefeeds in our bit.

    return throws_ok(sub { $sub->() }, 
		     qr/^Signature validation failed for $pkg->$name: [^\n]*$like[^\n]*$/m,
		     $msg);
  
}

sub mxms_dies_ok {
    my ($sub, $testsub_name, $msg) = @_;
    return mxms_throws_ok($sub, $testsub_name, qr//, $msg);
}

1;
