#!/usr/bin/env perl
use warnings;
use strict;
use 5.010;

$|=1;

my $namecoin_path = $ENV{NAMECOIN_PATH} or die "Not set NAMECOIN_PATH";
my $namecoind = $namecoin_path."/namecoind";
if (!-e $namecoind) {
    die $namecoind." does not exist";
}

if (!-x $namecoind) {
    die $namecoind." not exedutable";
}


my $filebc = $ARGV[0];
if (!defined $filebc) {
    die "You have to specify filename in blockchain.";
}

my $fileres = $ARGV[1];

if (!defined $fileres) {
    die "You have to specify output file";
}

{
    open my $blank, ">", $fileres or die "can't create $fileres";
    close $blank;
}


open my $outpf, " |base64 -d > $fileres" or die "can't run base64";

sub read_raw_data {
    my $key = shift;
    my $res = `$namecoind name_show $key 2>&1`;

    if ($res =~ /^error/) {
        die $res;
    }
    $res =~ /"value"\s*:\s*"([a-zA-Z0-9\/+|=]*)"/ or die "wrong format of $res";
    return $1;
}

#infinite loop prevention
my %visited;

my $begin = "fb/$filebc";
my $current = read_raw_data($begin);

my $i=0;
while (1) {
    if (exists $visited{$current}) {
        die "Twice in the same river.";
    }
    $i++;
    say "Downloading part $i";
    $visited{$current}=undef;
    my $read = read_raw_data("fp/".$current);
    $read =~ /^([a-zA-Z0-9\/+=]*)\|([a-z]*|END)$/ or die "Wrong data format.";

    my $base = $1;
    my $next = $2;
    print $outpf $base;
    if ($next eq "END") {
        last;
    }
    $current = $next;
}

close $outpf;
