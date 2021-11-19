all:
	npm run serve
d:
	npm run build
rsync:
	rsync -av renlab.sdsc.edu:/var/www/html/bil022/Finder/fastq.*.head.gz meta/.
	(gzcat meta/fastq.*.head.gz | awk '{print $$1,$$NF}'; gzcat meta/fastq.20*.head.gz) | meta/head.pl > public/items.json
	@rsync -av -q dist/* renlab.sdsc.edu:/var/www/html/bil022/Finder/v-finder/.
	@echo http://renlab.sdsc.edu/Finder/v-finder/
