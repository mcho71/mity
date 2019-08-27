.PHONY: check serve deploy post

check:
ifeq (,$(shell which hugo))
$(error "No hugo in PATH, requires hugo(https://github.com/gohugoio/hugo)")
endif

serve:
	@make check > /dev/null
	hugo server -D -w --cleanDestinationDir --gc --forceSyncStatic

build:
	@make check > /dev/null
	hugo --cleanDestinationDir --gc --forceSyncStatic

deploy:
	@make check > /dev/null
	./deploy.sh

post:
	@make check > /dev/null
	hugo new notes/${TITLE}.md