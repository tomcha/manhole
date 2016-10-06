#!/usr/bin/env perl

use strict;
use warnings;

use Term::Screen;
use Time::HiRes qw( usleep gettimeofday tv_interval );

my @left = qw(0 0 0 0 0 0);
my @center = qw(0 0 0 0 0 0 0 0);
my @right = qw(0 0 0 0 0 0);
my @end = qw(0 0 0);

my $miss = 0;
my $turn_of_side = 0;

my $scr = new Term::Screen;
unless ($scr) { die " Something's wrong \n"; }
my $score = 0;
my $manhole_locate = 'r';

my $start_hires = [gettimeofday];
my $interval = 1;
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
      input_key($c);
    };
    if (tv_interval($start_hires) > $interval){
      $start_hires = [gettimeofday];
      if ($turn_of_side == 0){
        $turn_of_side += 1;
        move_left();
        draw_walkman();
      }
      elsif ($turn_of_side == 1){
        $turn_of_side += 1;
        move_center();
        draw_walkman();
      }else {
        $turn_of_side = 0;
        move_right();
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
  for my $i (@left){
    $n += $i;
  }
  for my $j (@center){
    $n += $j;
  }
  for my $k (@right){
    $n += $k;
  }
  return $n;
}

sub default_screen{
  $scr->at(7,5);
  $scr->puts("~");
  $scr->at(7,11);
  $scr->puts(" ");
  $scr->at(7,16);
  $scr->puts(" ");
  $scr->at(5,19);
  $manhole_locate = 'l';
}

sub draw_score{
  $scr->at(0,0);
  $scr->puts("score: $score    miss: $miss");
}

sub draw_screen{
  $scr->at(2,1);
  $scr->puts("#");
  $scr->at(3,1);
  $scr->puts("##");
  $scr->at(4,1);
  $scr->puts("##");
  $scr->at(5,1);
  $scr->puts("##");
  $scr->at(6,1);
  $scr->puts("##");
  $scr->at(7,1);
  $scr->puts("##");
  $scr->at(8,1);
  $scr->puts("--------------------");
  $scr->at(6,18);
  $scr->puts("_-_");
  $scr->at(7,18);
  $scr->puts("o o");
}

sub draw_walkman{
  my @view_left = map {my $a = $_; $a =~ s/0/ /; $a} @left;
  $scr->at(2,2);
  $scr->puts($view_left[1]);
  $scr->at(3,4);
  $scr->puts($view_left[2]);
  $scr->at(4,5);
  $scr->puts($view_left[3]);
  $scr->at(5,5);
  $scr->puts($view_left[4]);
  $scr->at(6,5);
  $scr->puts($view_left[5]);
  my @view_center = map {my $a = $_; $a =~ s/0/ /; $a}@center;
  $scr->at(5,6);
  $scr->puts($view_center[0]);
  $scr->at(4,7);
  $scr->puts($view_center[1]);
  $scr->at(3,8);
  $scr->puts($view_center[2]);
  $scr->at(2,9);
  $scr->puts($view_center[3]);
  $scr->at(3,10);
  $scr->puts($view_center[4]);
  $scr->at(4,11);
  $scr->puts($view_center[5]);
  $scr->at(5,11);
  $scr->puts($view_center[6]);
  $scr->at(6,11);
  $scr->puts($view_center[7]);
  my @view_right = map{my $a = $_; $a =~ s/0/ /; $a}@right;
  $scr->at(5,12);
  $scr->puts($view_right[0]);
  $scr->at(4,13);
  $scr->puts($view_right[1]);
  $scr->at(3,14);
  $scr->puts($view_right[2]);
  $scr->at(4,15);
  $scr->puts($view_right[3]);
  $scr->at(5,16);
  $scr->puts($view_right[4]);
  $scr->at(6,16);
  $scr->puts($view_right[5]);
  my @view_end = map{my $a = $_; $a =~ s/0/ /; $a}@end;
  $scr->at(5,17);
  $scr->puts($view_end[0]);
  $scr->at(4,18);
  $scr->puts($view_end[1]);
  $scr->at(5,19);
  $scr->puts($view_end[2]);
  $scr->at(5,19);
}

sub input_key{
  my $c = shift;
  if ($c =~ /[jkq]/){
    if ($c eq 'j'){
      if ($manhole_locate eq 'c'){
        draw_manhole('l');
      }
      elsif ($manhole_locate eq 'r'){
        draw_manhole('c');
      }
    }
    elsif ($c eq 'k'){
      if ($manhole_locate eq 'c'){
        draw_manhole('r');
      }
      elsif ($manhole_locate eq 'l'){
        draw_manhole('c');
      }
    }
    elsif ($c eq 'q'){
      game_end();
    }
  }
}

sub draw_manhole{
  my $c = shift;
  if ($c eq 'l'){
    $scr->at(7,5);
    $scr->puts("~");
    $scr->at(7,11);
    $scr->puts(" ");
    $scr->at(7,16);
    $scr->puts(" ");
    $scr->at(5,19);
    $manhole_locate = 'l';
  }
  elsif ($c eq 'c'){
    $scr->at(7,5);
    $scr->puts(" ");
    $scr->at(7,11);
    $scr->puts("~");
    $scr->at(7,16);
    $scr->puts(" ");
    $scr->at(5,19);
    $manhole_locate = 'c';
  }
  elsif ($c eq 'r') {
    $scr->at(7,5);
    $scr->puts(" ");
    $scr->at(7,11);
    $scr->puts(" ");
    $scr->at(7,16);
    $scr->puts("~");
    $scr->at(5,19);
    $manhole_locate = 'r';
  }
}

sub move_left {
  add_walkman();
  pop @left;
  pop @end;
  unshift (@left, '0');
  unshift (@end, '0');
  if ($right[5] eq '1'){
    $right[5] = '0';
    $end[0] = '1';
  }
  if ($left[5] eq '1' && $manhole_locate ne 'l'){
    miss();
  }
  elsif ($left[5] eq '1' && $manhole_locate eq 'l'){
    add_score();
    draw_score();
  }
}

sub move_center{
  pop @center;
  unshift (@center, '0');
  if ($left[5] eq '1'){
    $left[5] = '0';
    $center[0] = '1';
  }
  if ($center[7] eq '1' && $manhole_locate ne 'c'){
    miss();
  }
  elsif ($center[7] eq '1' && $manhole_locate eq 'c'){
    add_score();
    draw_score();
  }
}

sub move_right{
  pop @right;
  unshift (@right, '0');
  if ($center[7] eq '1'){
    $center[7] = '0';
    $right[0] = '1';
  }
  if ($right[5] eq '1' && $manhole_locate ne 'r'){
    miss();
  }
  elsif ($right[5] eq '1' && $manhole_locate eq 'r'){
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
sub add_walkman{
  if (int(rand(100)) > 30){
    if (get_walkman_num() < get_lv($score)){
      $left[0] = '1';
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
    @left = qw(0 0 0 0 0 0);
    @center = qw(0 0 0 0 0 0 0 0);
    @right = qw(0 0 0 0 0 0);
    @end = qw(0 0 0);
    $lv = 1;
    draw_walkman();
  }
}

sub game_end{
    $scr = undef;
    exit(0);
}
1;
__END__
