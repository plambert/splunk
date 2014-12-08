#!/usr/bin/perl -w

use strict;
use warnings;

my $tag=shift;
my @attr;
my @reqattr;
my @children;
my $count=1;
my $attr;

while(@ARGV) {
  my $opt=shift @ARGV;
  if ($opt =~ s{^--}{}) {
    push @reqattr, attr_from_opt($opt);
  }
  elsif ($opt =~ s{^-}{}) {
    push @attr, attr_from_opt($opt);
  }
  else {
    push @children, child_from_opt($opt);
  }
}

sub attr_from_opt {
  my ($opt)=@_;
  my $attr={};
  if ($opt =~ m{(.*?)=(.*)}) {
    ($attr->{name}, $attr->{value}) = ($1, $2);
  }
  elsif ($opt =~ m{(.*?):(.*)}) {
    ($attr->{name}, $attr->{default}) = ($1, $2);
  }
  else {
    ($attr->{name}, $attr->{default}) = ($1, '...');
  }
  return $attr;
}

sub child_from_opt {
  my ($opt)=@_;
  my $child={ list => 1 };
  if ($opt =~ s{^\+}{}) {
    $child->{list} = 0;
  }
  if ($opt =~ m{^(.*?)=(.*)}) {
    $child->{name}=$1;
    $child->{value}=$2;
  }
  else {
    $child->{name}=$opt;
  }
  return $child;
}

sub print_attr {
  my ($cnt, $attr, $opts) = @_;
  for (keys %$opts) {
    $attr->{$_}=$opts->{$_} unless (exists $attr->{$_});
  }
  unless ($attr->{req}) {
    printf "\${%d:", $cnt;
    $cnt += 1;
  }
  if (defined($attr->{value})) {
    printf " %s=\"%s\"", $attr->{name}, $attr->{value};
  }
  else {
    printf " %s=\"\${%d:%s}\"", $attr->{name}, $cnt, $attr->{default};
    $cnt += 1;
  }
  unless ($attr->{req}) {
    printf "}";
  }
  return $cnt;
}

sub print_children {
  my $cnt=shift;
  for my $child (@_) {
    if (defined($child->{value})) {
      printf "  <%s>\${%d:%s}</%s>\n", $child->{name}, $cnt, $child->{value}, $child->{name};
      $cnt += 1;
    }
  }
  return $cnt;
}

printf "<%s", $tag;
for $attr (@reqattr) {
  $count=print_attr($count, $attr, { req => 1 });
}
if (@attr) {
  printf "\$\{%d:", $count;
  $count += 1;
  for $attr (grep { !$_->{req} } @attr) {
    $count=print_attr($count,$attr);
  }
  printf "}";
}
printf ">\n";
$count=print_children($count, @children);

if (@children) {
  printf "  \$\{0:<!-- continue: %s ... -->\}\n", join(", ", sort map { $_->{name} } grep { $_->{list} } @children);
}
else {
  printf "  \$0\n";
}

printf "</%s>\n", $tag;

