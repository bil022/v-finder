all:
	(gzcat fastq.*.head.gz | awk '{print $$1,$$NF}'; gzcat fastq.20*.head.gz) | ./head.pl > ../public/items.json
