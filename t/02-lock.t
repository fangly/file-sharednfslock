#! perl

use strict;
use warnings;
use Test::More;
use Config;

BEGIN {
   if ($Config{useithreads}) {
      require threads;
   } else {
      plan skip_all => 'Need Perl with thread support for these tests';
   }
};


use Time::HiRes ();

use File::SharedNFSLock;

my $some_file = 'some_file_on_nfs';
my $lock_file = 'some_file_on_nfs.lock';

my $thr1 = threads->create(\&worker1);
my $thr2 = threads->create(\&worker2);

my @finished;
while ( threads->list() ) { # number of non-joined, non-detached threads
   for my $joinable ( threads->list(threads::joinable) ) {
      push @finished, $joinable->tid;
      $joinable->join;
   }
}

is_deeply \@finished, [1,2], 'Thread 1 blocked thread 2';


sub worker1 {
   my ($delay, $msg) = @_;
   my $status = 0;
   my $flock = File::SharedNFSLock->new(
      file => $some_file,
   );
   $flock->lock;
   Time::HiRes::sleep(0.4); # do something on file...
   $flock->unlock;
   return 1;
}

sub worker2 {
   my ($delay) = @_;
   Time::HiRes::sleep(0.1);
   my $flock = File::SharedNFSLock->new(
      file => $some_file,
   );
   $flock->lock; # wait for worker1 to be done
   $flock->unlock;
   return 1;
}


done_testing();
