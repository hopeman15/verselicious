all: lint test analyze
.PHONY: all

install:
	bundle install
.PHONY: install

lint:
	bundle exec rubocop
.PHONY: lint

lint-fix:
	bundle exec rubocop -A
.PHONY: lint-fix

test:
	bundle exec rspec --exclude-pattern 'spec/integration/**/*_spec.rb'
.PHONY: test

integration:
	INTEGRATION_TEST=true bundle exec rspec spec/integration
.PHONY: integration

analyze:
	bundle exec reek lib/
	bundle exec flay lib/
	bundle exec flog --all lib/
.PHONY: analyze
