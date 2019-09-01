help:
	@echo 'Makefile for gift-registry-api                                        				'
	@echo '                                                                      				'
	@echo 'Usage:                                                                				'
	@echo '   run                     Run api in localhost:8888                  				'
	@echo '   setup                   Install all dependencies to dev            				'
	@echo '   db-clean                Delete all DBs and create new ones         				'
	@echo '   test                    Run all tests                              				'
	@echo '   test-cov                Run all tests with coverage result on browser (LINUX only)'
	@echo '   auto-test               Automated tests init                       				'

setup:
	gem install bundler
	bundle install
	@make db-create

run:
	bundle exec jets server

db-clean:
	bundle exec  jets db:drop
	@make db-create

db-create:
	bundle exec jets db:create db:migrate
	bundle exec jets db:seed

test:
	JETS_ENV=test bundle exec jets db:create db:migrate
	rspec

test-cov:
	@make test
	sensible-browser ./coverage/index.html

auto-test:
	JETS_ENV=test bundle exec jets db:create db:migrate
	bundle exec guard

.PHONY: help, setup, run, clean, test, test-cov, auto-test