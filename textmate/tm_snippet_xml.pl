#!/usr/bin/perl -w

my $USAGE=<<USAGE;
# ugly script to produce quick xml snippets for splunk xml items

# tm_snippet_xml.pl <tagname> [options...]

# tagname is the name of the tag itself

# the options are weird; the intention is to be compact, not to be clear.  clear would be to write out the snippets.  :)

# option                      explanation
# ----------                  ---------------------------------------------------------------------------------------------------
#  -foo                       add an optional attribute "foo" with a default value of "..."
#  -foo:bar                   add an optional attribute "foo" with a default value of "bar"
#  -foo=bar                   add an optional attribute "foo" with a fixed (not edited) value of "bar"
# --foo                       add a mandatory attribute "foo" with a default value of "..."
# --foo:bar                   add a mandatory attribute "foo" with a default value of "bar"
# --foo=bar                   add a mandatory attribute "foo" with a fixed (not edited) value of "bar"
#   foo                       list "foo" as a next step, do not include an actual "foo" tag
#   foo=bar                   list "foo" as a next step, include a simple "foo" node with a default value of "bar"
#  +foo                       do not list "foo" as a next step; this is not very useful
#  +foo=bar                   do not list "foo" as a next step, but do include a simple "foo" node with a default value of "bar"
#  -1                         leave result on one line
USAGE

use strict;
use warnings;

my $tag=shift;
my @attr;
my @reqattr;
my @children;
my $count=1;
my $attr;
my $builddir;
my $snippetname=$tag;
my $oneline=1;

unless (defined($tag)) {
  $USAGE =~ s{^# }{}mg;
  print STDERR $USAGE;
  print STDERR "\n$0: error: no tag given\n";
  exit 1;
}

if (-d "build") {
  $builddir="build";
}
elsif (-d "../build") {
  $builddir="../build";
}
elsif (-d "../../build") {
  $builddir="../../build";
}
else {
  die "$0: build: cannot find build directory ./build, ../build, or ../../build\n";
}

if (grep { m{^--type=} } @ARGV) {
  for (@ARGV) {
    if (m{^--type=(.*)}) {
      $snippetname="${tag}-$1";
      last;
    }
  }
}

unless (open(SNIPPET, ">", "${builddir}/${snippetname}.snippet")) {
  die "$0: ${builddir}/${snippetname}.snippet: could not open for writing: $!\n";
}
select(SNIPPET);

while(@ARGV) {
  my $opt=shift @ARGV;
  if ($opt eq '-1') {
    $oneline=1;
  }
  elsif ($opt eq '-2') {
    undef $oneline;
  }
  elsif ($opt =~ s{^--}{}) {
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
    ($attr->{name}, $attr->{default}) = ($opt, '...');
  }
  return $attr;
}

sub child_from_opt {
  my ($opt)=@_;
  my $child={ list => 1 };
  if ($opt =~ s{^\+}{}) {
    $child->{list} = 0;
  }
  if ($opt =~ m{^\.(.*?)(?:::(.*?))?(?::(.*?))?(\?)?$}) {
    $child->{opt}=$1;
    $child->{alt}=$2 if (defined($2));
    $child->{default}=$3 if (defined($3));
    $child->{del}=1 if (defined($4));
    $child->{list}=0;
  }
  elsif ($opt =~ m{^(.*?)=(.*)}) {
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
    undef $oneline if (defined($child->{opt}) or defined($child->{value}));
    if (defined($child->{opt})) {
      $cnt=print_option($cnt, $child);
    }
    elsif (defined($child->{value})) {
      printf "%s<%s>\${%d:%s}</%s>\n", ($oneline ? "" : "  "), $child->{name}, $cnt, $child->{value}, $child->{name};
      $cnt += 1;
    }
  }
  return $cnt;
}

# opt, alt, default, del
sub print_option {
  my ($cnt, $child) = @_;
  printf "  " unless ($oneline);
  if (defined($child->{del}) and $child->{del}) {
    printf "\$\{%d:", $cnt;
    $cnt+=1;
  }
  printf "<option name=\"%s\">", $child->{opt};
  if (defined($child->{alt})) {
    printf "\$\{%d|%s\}", $cnt, $child->{alt};
    $cnt += 1;
  }
  else {
    $child->{default}='...' unless (defined($child->{default}));
    printf "\$\{%d:%s\}", $cnt, $child->{default};
    $cnt += 1;
  }
  printf "</option>";
  if (defined($child->{del}) and $child->{del}) {
    printf "}";
  }
  printf "\n";
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
printf ">%s", $oneline ? "" : "\n";
$count=print_children($count, @children);

printf "%s", ($oneline ? "" : "  ");
if (@children) {
  printf "\$\{0:<!-- continue: %s ... -->\}", join(", ", sort map { $_->{name} } grep { $_->{list} } @children);
}
else {
  printf "\$0";
}
printf "\n" unless ($oneline);

printf "</%s>\n", $tag;

select(STDOUT);
close(SNIPPET);

system "cat", "${builddir}/${snippetname}.snippet"

