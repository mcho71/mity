check:
ifeq (,$(shell which hugo))
$(error "No hugo in PATH, requires hugo(https://github.com/gohugoio/hugo)")
endif

serve:
	@make check > /dev/null
	hugo server -D -w

deploy:
	@make check > /dev/null
	./deploy.sh

t := draft
post:
	@make check > /dev/null
	hugo new posts/${t}.md