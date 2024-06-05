#!/usr/bin/perl -w
#
# tests/make-ca.t

use Test::More qw( no_plan );

my @script_list = (
    'bin/wallet',
    );

for my $this_script (@script_list) {
    my $s = "../usr/${this_script}";

    my $t1 = `$s help 2>&1`;
    my $hname = "${this_script} Help display";
    if ($t1) {
        if (!ok ($t1 =~ /^Usage/, $hname)) {
            print 'INFO: ' . $s . ' --help 2>&1' . "\n";
            print "ERROR: $t1\n";
        }
    } else {
        fail("${this_script} Help switch" . ' -- no output');
    }

    my $t = "${s}.tdy";
    my @cmd = ('perltidy');
    push @cmd, '-bbao';  # put line breaks before any operator
    push @cmd, '-nbbc';  # don't force blank lines before comments
    push @cmd, '-ce';    # cuddle braces around else
    push @cmd, '-l=79';  # don't want 79-long lines reformatted
    push @cmd, '-pt=2';  # don't add extra whitespace around parentheses
    push @cmd, '-sbt=2'; # ...or square brackets
    push @cmd, '-sfs';   # no space before semicolon in for
    push @cmd, $s;
    system(@cmd);
    my $out = `/usr/bin/diff -u $s $t`;
    my $tname = "$this_script tidy test";
    if ($out) {
        fail($tname);
        print "$this_script is UNTIDY\n";
        print $out;
    } else {
        pass($tname);
    }
    unlink $t;

    my $err_file = "${s}.ERR";
    if (-e $err_file) {
        open(my $fd, '<', $err_file);
        while (<$fd>) {
            print $_;
        }
        close $fd;
        fail("Error file created");
    }
}
