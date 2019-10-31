.PHONY: check serve deploy post

setup:
	git submodule init
	git submodule update
	@make check

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

post:
	@make check > /dev/null
	hugo new posts/${TITLE}.md

diary:
	@make check > /dev/null
	hugo new -k diary diaries/`date "+%Y-%m-%d"`.md

memo:
	@make check > /dev/null
	hugo new memos/${TITLE}.md

note:
	@make check > /dev/null
	hugo new notes/${TITLE}.md
