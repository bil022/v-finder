#!/usr/bin/perl

while (<DATA>) { chomp();
  ($id, $who)=split(/\t/,$_);
  $WHOIS{$id}=$who;
  # print "$id is $who\n"; 
}

while (<>) {
	@data=split();
	die $_ unless (@data==4 || @data==5);
	($path, $size, $tm, $head, $tag)=@data;
	die unless $path=~/^\/projects\/ps-renlab\/fastq\/(\S+)\/(\S+)$/;
	($short_path, $file)=($1, $2);
	if ($short_path=~/(\d\d\d\d)_(\d\d)_(\d\d)/) {
		($y, $m, $d)=($1,$2,$3);
	} elsif ($short_path=~/(\d\d\d\d)_(\d\d)(\d\d)_/) {
		($y, $m, $d)=($1,$2,$3);
	} elsif ($short_path=~/_(\d\d)(\d\d)(20\d\d)_/) {
		($y, $m, $d)=($3,$1,$2);
	} else {
		die $short_path;
	}
	die unless $d<=31 && $m<=12; $mdy="$m/$d/$y";
    ## $short_path, $file, $mdy, $size

	if ($tag) {
		# https://kscbioinformatics.wordpress.com/2017/02/03/raw-illumina-sequence-data-files-for-dummies-part-1/
		if ($head=~/^(\S+):(\d+):(\S+):(\d):(\d+):(\d+):(\d+)$/) {
			($machine, $rid, $fcid, $ln, $tile, $x, $y)=($1,$2,$3,$4,$5,$6,$7);
		} elsif ($head=~/^(\S+):(\d+):(\S+):(\d):(\d+):(\d+):(\d+):(\S+)$/) {
			# @VH00454:6:AAAKTJ3M5:1:1102:47676:10977:TGAGAGGCTA 
			($machine, $rid, $fcid, $ln, $tile, $x, $y, $seq0)=($1,$2,$3,$4,$5,$6,$7,$8);
		} else {
			die $_;
		}
		die $_ unless $tag=~/^(\d):([YN]):(\d):(\S*)$/;
		($pair, $filtered, $ctl, $idx)=($1,$2,$3,$4);
        ## $machine, $rid, $fcid, $ln, $tile, $x, $y, [$seq0], $pair, $filtered, $ctl, $idx
	} else {
		# https://en.wikipedia.org/wiki/FASTQ_format
		if ($head=~/^(\S+)_(\d+):(\d):(\d+):(\d+):(\d+)#(\S+)\/(\d)$/) {
			($machine, $run, $ln, $tile, $x, $y, $idx, $pair)=($1,$2,$3,$4,$5,$6,$7,$8);
		} elsif ($head=~/^(\S+)_(\d+):(\d):(\d+):(\d+):(\d+)$/) {
            ($machine, $run, $ln, $tile, $x, $y)=($1,$2,$3,$4,$5,$6);
		} else {
			die $_;
		}
        $fcid="${machine}_$run";
        ## $machine,   $run         $ln, $tile, $x, $y,         [$pair],                [$idx]
	}
    ## $machine, $fcid_or_run
    $key="$short_path.$fcid";
    $run_info="\"path\": \"$short_path\", \"fcid\": \"$fcid\", \"mdy\": \"$mdy\", \"machine\": \"$machine\"";
    if (exists $INFO{$key}) {
        # make sure same: $path, $fcid, $date, $machine are the same
        die $_ unless $run_info eq $INFO{$key};
    } else {
        # add $short_path, $fcid, $date & $machine
        $INFO{$key}=$run_info;
    }
    # push: $file, $size
    $who=""; $uid="N/A"; $who="";
    $uid=$1 if $file=~/([a-zA-Z]+)/;
    $who=$WHOIS{$uid} if exists $WHOIS{$uid};
 
    $files="{ \"file\": \"$file\", \"size\": \"$size\", \"owner\": \"$who\" }";
    push(@{$LST{$key}}, $files);
}

sub byDate {
    die $INFO{$a} unless $INFO{$a}=~/"mdy": "(\d+)\/(\d+)\/(\d+)"/; ($ma,$da,$ya)=($1,$2,$3);
    die $INFO{$b} unless $INFO{$b}=~/"mdy": "(\d+)\/(\d+)\/(\d+)"/; ($mb,$db,$yb)=($1,$2,$3);
    return $yb<=>$ya if $ya!=$yb;
    return $mb<=>$ma if $ma!=$mb;
    return $db<=>$da if $da!=$db;
    return $a<=>$b;
}

print "[\n"; $N=0;
foreach $k (sort byDate keys %INFO) {
	print ",\n" if $N++;
    print("{ $INFO{$k}, \"hasSampleSheet\": \"false\", \"hasDoc\": \"false\",\"files\": [\n".join(",\t\n", @{$LST{$k}})."]}");
}
print "\n]";

__END__
RH	Rong Hu
JY	Jian Yan
SRC	Sora Chee
AY	Ah Young Lee
ADS	Anthony Schmitt
MY	Miao Yu
SP	Sebastian Preissl
CZ	Chenxu Zhu
JL	Jason Li
DG	David Gorkin
NK	Naoki Kubo
HH	Hui Huang
RZY	Zhen Ye
YD	Yarui Diao
GH	Gary Hon
YX	Yang Xie
BC	Benson Chen
