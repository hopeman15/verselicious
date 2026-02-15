all: format lint analyze test integration
.PHONY: all

analyze:
	bundle exec reek lib/
	bundle exec flay lib/
	bundle exec flog --all lib/
.PHONY: analyze

format:
	bundle exec rubocop -A
.PHONY: format

install:
	bundle install
.PHONY: install

integration:
	INTEGRATION_TEST=true bundle exec rspec spec/integration
.PHONY: integration

lint:
	bundle exec rubocop
.PHONY: lint

test:
	bundle exec rspec --exclude-pattern 'spec/integration/**/*_spec.rb'
.PHONY: test
