#!/usr/bin/env perl
use warnings;
use strict;
use 5.010;
sub tsay {
    print scalar localtime;
    print " : ";
    say @_;
}

$|=1;

my $namecoin_path = $ENV{NAMECOIN_PATH} or die "Not set NAMECOIN_PATH";
my $namecoind = $namecoin_path."/namecoind";
if (!-e $namecoind) {
    die $namecoind." does not exist";
}

if (!-x $namecoind) {
    die $namecoind." not exedutable";
}

my $file = $ARGV[0];
if (!-e $file) {
    die "File $file does not exist.";
}

my $filebc = $ARGV[1];
if (!defined $filebc) {
    die "You have to specify filename in blockchain.";
}

if (!is_string_free("fb", $filebc)) {
    die "Filename is not free in blockchain.";
}

sub check_number_of_confirmations {
    my $id = shift;
    my $res = `$namecoind gettransaction $id 2>&1`;
    if ($res =~ /^error/) {
        die $res;
    }
    
    $res =~ /"confirmations"\s*:\s*(\d+)\s*,/ or die "wrong format";
    return $1;
}

my $waiting_interval = 120;
sub wait_for_confirmations {
    my $id = shift;
    my $howmuch = shift;
    while (1) {
        my $confirmations = check_number_of_confirmations($id);
        if ($confirmations >= $howmuch) {
            return;
        }
        sleep($waiting_interval);
    }
}

sub wait_for_registration {

    my $string = shift;

    while (1) {
        my $is = is_string_free_whole($string);
        if (!$is) {
            return;
        }
        sleep($waiting_interval);
    }
}


tsay "Generating base 64...";
#I do base64 because I want to treat the file as a text
#even when it's binary
my $base64 = `cat $file | base64 -w 0`;

tsay "Splitting and generating random names...";

my @splitbase = unpack("(A450)*",  $base64);

my @letters = ('a'..'z');
sub generate_random_string {
    my $res="";
    for (1..20) {
        $res = $res.$letters[rand(scalar @letters)];
    }
    return $res;
}

sub is_string_free {
    my $domain = shift;
    my $string = shift;
    return is_string_free_whole($domain."/".$string);
}

sub is_string_free_whole {
    my $string = shift;
    my $res = `$namecoind name_show $string 2>&1`;
    if ($res =~ /^error/) {
        return 1;
    }
    return 0;
}

sub generate_random_unique_string {
    my $res;
    do {
        $res = generate_random_string();
    } while (!is_string_free("fp", $res));
    return $res;
}

my @parts = map {{value=>$_, name=>generate_random_unique_string()}} @splitbase;

$parts[-1]->{'next'}='END';
for my $i (0..scalar @parts-2) {
    $parts[$i]->{'next'} = $parts[$i+1]->{'name'};
}

my @pairs_to_send = map {{key=>"fp/".$_->{name}, value=>$_->{value}."|".$_->{'next'}}} @parts;
unshift (@pairs_to_send, {key=>"fb/$filebc", value=>$parts[0]->{name}});



tsay "Announcing name_new...";

my $i=0;
for my $pair (@pairs_to_send) {
    $i++;
    tsay "$i from ".(scalar @pairs_to_send);
    my $key = $pair->{key};
    my $res = `$namecoind name_new $key 2>&1`;
    
    if ($res =~ /\[\s*"([^"]*)"\s*,\s*"([^"]*)"\s*\]/) {
        $pair->{announce_trx} = $1;
        $pair->{'rand'} = $2;
    } else {
        die "error with announcing $key - $res";
    }
}

tsay "Waiting for one initial confirmation (about 10-30 minutes)";


for my $pair (@pairs_to_send) {
     wait_for_confirmations($pair->{announce_trx}, 1);
     #tsay "DEBUG - done - ".$pair->{announce_trx};
}

$i=0;
tsay "Putting the file parts into the p2p network...";
for my $pair (@pairs_to_send) {
    $i++;
    tsay "$i from ".(scalar @pairs_to_send);
    my $rand = $pair->{'rand'};
    my $name = $pair->{'key'};
    my $val = $pair->{'value'};
    my $res = `$namecoind name_firstupdate $name $rand '$val' 2>&1`;
    if ($res =~ /^error/) {
        die $res;
    }
}

tsay "Waiting for the file parts to appear in blockchain (about 90 minutes)";
tsay "(you can kill this process now, you don't have to wait)";
for my $pair (@pairs_to_send) {
     wait_for_registration($pair->{'key'});
}

tsay "Success! The file is now in blockchain!";

