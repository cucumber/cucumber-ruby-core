release:
	[ -d '../secrets' ]  || git clone keybase://team/cucumberbdd/secrets ../secrets
	git -C ../secrets pull
	../secrets/update_permissions
	docker run \
		--volume "${shell pwd}":/app \
		--volume "${shell pwd}/../secrets/import-gpg-key.sh":/home/cukebot/import-gpg-key.sh \
		--volume "${shell pwd}/../secrets/codesigning.key":/home/cukebot/codesigning.key \
		--volume "${shell pwd}/../secrets/.ssh":/home/cukebot/.ssh \
		--volume "${shell pwd}/../secrets/.gem":/home/cukebot/.gem \
		--volume "${HOME}/.gitconfig":/home/cukebot/.gitconfig \
		--env-file ../secrets/secrets.list \
		--user 1000 \
		--rm \
		-it cucumber/cucumber-build:latest \
		bash -c "rm -f Gemfile.lock && bundle && bundle exec rake && bundle exec rake release"
.PHONY: release
