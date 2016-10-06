#!/usr/bin/env perl

use strict;
use warnings;

use Term::Screen;
use Time::HiRes qw( usleep gettimeofday tv_interval );

my @upside = qw(0 0 0 0 0 0 0 0 0 0 0);
my $upside_walkman = 0;
my @downside = qw(0 0 0 0 0 0 0 0 0 0 0);
my $downside_walkman = 0;

my $miss = 0;

my $scr = new Term::Screen;
unless ($scr) { die " Something's wrong \n"; }
my $score = 0;
my $manhole_locate = 'u';

my $start_hires = [gettimeofday];
my $interval = 1;
my $turn_of_updown = 0;
my $lv = 1;

$scr->noecho();
$scr->clrscr();
unless ($scr) { die " Something's wrong \n"; }
print 'hit space key!';
game_main();

sub game_main{
  default_screen();
  draw_screen();
  draw_score();
  my $c;

  while (1){
    if ($scr->key_pressed){
      $c = $scr->getch();
      draw_manhole($c);
    };
    if (tv_interval($start_hires) > $interval){
      $start_hires = [gettimeofday];
      if ($turn_of_updown == 0){
        $turn_of_updown = 1;
        move_upside();
        draw_walkman();
      }
      else{
        $turn_of_updown = 0;
        move_downside();
        draw_walkman();
      }
    }
  }
}
sub set_interval{
  if ($lv < 10){
    $interval -= 0.1 * $lv;
  }
}

sub get_lv{
  my $score = shift;
  my $lv = int($score / 10) + 1;
  return $lv;
}

sub get_walkman_num{
  my $n = 0;
  for my $i (@upside){
    $n += $i;
  }
  for my $j (@downside){
    $n += $j;
  }
  return $n;
}

sub default_screen{
  $scr->clrscr();
  $scr->at(6,10);
  $scr->puts("~");
}

sub draw_score{
  $scr->at(0,1);
  $scr->puts("score: $score");
  $scr->at(1,1);
  $scr->puts("miss : $miss");
}

sub draw_screen{
  my $c = shift;
  $scr->at(5,3);
  $scr->puts(" _ _ _   _ _   _ _ _");
  $scr->at(8,3);
  $scr->puts(" _ _ _   _ _   _ _ _");
}

sub draw_walkman{
  $scr->at(4, 2);
  my @view_upside = map {my $a = $_; $a =~ s/0/ /; $a} @upside;
  $scr->puts("@view_upside");
  $scr->at(7, 4);
  my @view_downside = map{my $a = $_; $a =~ s/0/ /; $a}@downside;
  $scr->puts("@view_downside");
}

sub draw_manhole{
  my $c = shift;
  if ($c !~ /[uijkq]/){
    $c = $manhole_locate;
  }
  if ($c eq 'u') {
    $scr->at(6,10);
    $scr->puts("~");
    $scr->at(6,16);
    $scr->puts(" ");
    $scr->at(9,10);
    $scr->puts(" ");
    $scr->at(9,16);
    $scr->puts(" ");
    $scr->at(0,0);
    $manhole_locate = 'u';
  }
  elsif ($c eq 'i'){
    $scr->at(6,10);
    $scr->puts(" ");
    $scr->at(6,16);
    $scr->puts("~");
    $scr->at(9,10);
    $scr->puts(" ");
    $scr->at(9,16);
    $scr->puts(" ");
    $scr->at(0,0);
    $manhole_locate = 'i';
  }
  elsif ($c eq 'j'){
    $scr->at(6,10);
    $scr->puts(" ");
    $scr->at(6,16);
    $scr->puts(" ");
    $scr->at(9,10);
    $scr->puts("~");
    $scr->at(9,16);
    $scr->puts(" ");
    $scr->at(0,0);
    $manhole_locate = 'j';
  }
  elsif ($c eq 'k'){
    $scr->at(6,10);
    $scr->puts(" ");
    $scr->at(6,16);
    $scr->puts(" ");
    $scr->at(9,10);
    $scr->puts(" ");
    $scr->at(9,16);
    $scr->puts("~");
    $scr->at(0,0);
    $manhole_locate = 'k';
  }
  elsif ($c eq 'q'){
    game_end();
  };
}

sub move_upside{
  add_walkman();
  pop @upside;
  unshift (@upside,'0');
  if (($upside[4] eq '1' && $manhole_locate ne 'u') || ($upside[7] eq '1' && $manhole_locate ne 'i')){
    miss();
  }
  elsif (($upside[4] eq '1' && $manhole_locate eq 'u') || ($upside[7] eq '1' && $manhole_locate eq 'i')){
    add_score();
    draw_score();
  }
}
sub add_score{
  $score++;
  if ($score % 10 == 0){
    set_interval();
  }
}
sub move_downside{
  add_walkman();
  shift @downside;
  push (@downside,'0');
  if (($downside[3] eq '1' && $manhole_locate ne 'j') || ($downside[6] eq '1' && $manhole_locate ne 'k')){
    miss();
  }
  elsif (($downside[3] eq '1' && $manhole_locate eq 'j') || ($downside[6] eq '1' && $manhole_locate eq 'k')){
    add_score();
    draw_score();
  }
}
sub add_walkman{
  if (int(rand(100)) > 10){
    if (get_walkman_num() < get_lv($score)){
      if ($turn_of_updown == 1){
        $upside[0] = '1';
      }
      else{
        $downside[10] = '1';
      }

      if ($upside[3] eq '1'){
        $upside[0] = '0';
      }
      if ($downside[7] eq '1'){
        $downside[10] = '0';
      }
    }
  }
}

sub miss{
  draw_walkman();
  for (1..3){
    $scr->at(7, 10);
    $scr->puts('Miss !!');
    Time::HiRes::sleep(0.3);
    $scr->at(7, 10);
    $scr->puts('       ');
    Time::HiRes::sleep(0.3);
  }
  $miss++;
  draw_score();
  if ($miss == 3){
    $scr->at(7, 10);
    $scr->puts('GAME OVER');
    game_end();
  }
  else{
    @upside = qw(0 0 0 0 0 0 0 0 0 0 0);
    @downside = qw(0 0 0 0 0 0 0 0 0 0 0);
    draw_walkman();
  }
}

sub game_end{
    $scr = undef;
    exit(0);
}
1;
__END__
