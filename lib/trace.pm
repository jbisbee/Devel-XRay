package trace;
use warnings;
use strict;
use Filter::Simple;
use Carp qw(croak);
our $VERSION = '0.52';

BEGIN {
    warn "trace has been renamed to Devel::XRay";

    use constant DEBUG => 0;

    unless (exists $INC{"Time/HiRes.pm"}) {
	eval { require Time::HiRes; };
    }
    our $timing = exists $INC{"Time/HiRes.pm"} ? 
	'sprintf("%.6f", &Time::HiRes::time())' : 'sprintf("%d", time)';
    
    our %operations = (
        only   => \&_only,
        ignore => \&_ignore,
        all    => \&_all,
	none   => \&_none,
    );

    our $operation;
    our $subs = "";
    our $trace = ' print STDERR "[" . ' . $timing . ' . "] " . (caller(0))[3] . "\\n";';
    our $all_regex = qr/(sub{|sub[^\w].*?{)/;
    our $regex = "";

    sub import {
        (my ($class), $operation, my(@subs)) = @_;
        
        if ($operation) {
            croak "unknown import operation: $operation"
                unless exists $operations{$operation};
            croak "sub list required for operation: $operation\n" 
		unless $operation eq 'all' || $operation eq 'none' || @subs;
	    $regex = '(sub\s+(?:' . join("|", @subs) . ')\s*\{)';
	    $regex = $regex . quotemeta($trace) if $operation eq "ignore";
	    #warn "regex: $regex\n";
	    $regex = qr/$regex/;

        }
        else {
            $operation = "all";
        }
    }
    
    sub _only   { s/$regex/$1$trace/sg; }
    sub _ignore { _all($_); s/$regex/$1/sg; }
    sub _all    { s/$all_regex/$1$trace/sg; }
    sub _none   { }

    FILTER { 
	return unless $_;
	warn "performing operation: $operation\n" if DEBUG;
	$operations{$operation}->($_);
	warn $_ . "\n" if DEBUG;
    }
}

=head1 NAME

trace - sufficiently advanced way to trace subroutine calls

=head1 SYNOPSIS

use trace along with C<ignore>, C<only>, or C<all>,

    use trace;
    use trace 'all';    # same as saying 'use trace;'
    use trace 'none';   # filter the source but don't insert anything
    use trace ignore => qw(man_behind_curtain skeletons_in_closet _private);
    use trace only   => qw(sex drugs rock_and_roll);

=head1 DESCRIPTION

trace is a source filter using L<Filter::Simple> that prints the fully
qualified subroutine name (package::subroutine) to standard error as the 
program runs. 

This module is useful if...

=over 4

=item * 

You're a visual learner and want to "see"  program execution

=item *  

You're tracking an anomaly that leads you into unfamiliar code

=item *  

You want to quickly see how a module _runs_

=item *  

You've inherited code and need to grok it

=item *  

You start a new job and want to get a fast track on how things work

=back

=head1 EXAMPLES

    #!/usr/bin/perl
    use strict;
    use warnings;
    use trace;

    use Example::Object;

    init();
    my $example = Example::Object->new();
    my $name = $example->name();
    my $result = $example->calc();
    cleanup();

    sub init    {}
    sub cleanup {}

    # In a another file, say Example/Object.pm
    package Example::Object;
    use trace;
    sub new { bless {}, shift }
    sub name {}
    sub calc {}

Produces the following output

    # Hires seconds     # package::sub
    [1092265261.834574] main::init
    [1092265261.836732] Example::Object::new
    [1092265261.837563] Example::Object::name
    [1092265261.838245] Example::Object::calc
    [1092265261.839443] main::cleanup

=head1 BUGS

Please report any bugs or feature requests to C<bug-trace@rt.cpan.org>, 
or through the web interface at L<http://rt.cpan.org>.  I will be notified, 
and then you'll automatically be notified of progress on your bug as I 
make changes.

=head1 MAD PROPS

This module was inspired by Damian Conway's Sufficently Advanced 
Technology presentation at YAPC::NA 2004.  I had initially attempted 
to use L<Hook::LexWrap>, but using L<Filter::Simple> just seemed to 
be magical (and the first iteration was only 2 lines of code)

    package trace;
    use strict;
    use warnings;
    use Filter::Simple;

    my $code = 'print STDERR (caller(0))[3] . "\n";';
    FILTER { return unless $_; $_ =~ s/(sub.+?{)/$1 $code/sg; }

Also, I'd like to give a shout out goes to fellow SouthFlorida.pm homeboy and dark master
of POE, Rocco Caputo, for pairing with me to work out the import logic.   Rock on Rocco!

And my final props go out to the wild man Dennis Taylor, author of POE::Component::IRC, 
where I saw my first C<=head1 MAD PROPS> section.   Maybe someday someone will 
see this C<MAD PROPS> section and it will inspire them to send C<MAD PROPS> back my way.  
A man has to have his dream... :D

=head1 AUTHOR

Copyright 2004 Jeff Bisbee <jbisbee@cpan.org>

http://search.cpan.org/~jbisbee/

=head1 LICENSE

Copyright 2004 Jeff, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SEE ALSO

L<Filter::Simple>, L<Time::HiRes>, L<Hook::LexWrap>, L<Devel::Trace>

=cut

1;
