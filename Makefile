all:
	npm run serve
d:
	npm run build
rsync:
	rsync -av renlab.sdsc.edu:/var/www/html/bil022/Finder/fastq.*.heads.gz meta/.
	@rsync -av -q dist/* renlab.sdsc.edu:/var/www/html/bil022/Finder/v-finder/.
	@echo http://renlab.sdsc.edu/Finder/v-finder/
