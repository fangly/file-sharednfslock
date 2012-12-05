#! perl

use strict;
use warnings;
use Test::More;

use File::SharedNFSLock;

my $some_file = 'some_file_on_nfs';
my $lock_file = 'some_file_on_nfs.lock';

# Standard mode

ok my $flock = File::SharedNFSLock->new(
    file => $some_file,
), 'Standard mode';

ok not $flock->got_lock;
ok not $flock->locked;
ok not -f $lock_file;

isa_ok $flock, 'File::SharedNFSLock';

ok $flock->lock;

ok $flock->got_lock;
ok -f $lock_file;

ok $flock->unlock;

ok not $flock->locked;
ok not -f $lock_file;

ok $flock->wait;


# Compatibility mode

ok $flock = File::SharedNFSLock->new(
    file => $some_file,
), 'Compatibility mode';
$flock->_compat('silent');

ok not $flock->got_lock;
ok not $flock->locked;
ok not -f $lock_file;

ok $flock->lock;

ok $flock->got_lock;
ok -f $lock_file;

ok $flock->unlock;

ok not $flock->locked;
ok not -f $lock_file;

ok $flock->wait;


done_testing();
