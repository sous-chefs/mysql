This cookbook includes support for running tests via Test Kitchen (1.0). This has some requirements.

1. You must be using the Git repository, rather than the downloaded cookbook from the Chef Community Site.
2. You must have Vagrant 1.1 installed.
3. You must have a "sane" Ruby 1.9.3 environment.

Once the above requirements are met, install the additional requirements:

* Install bundler.

        [sudo] gem install bundler

* Tell bundler where the testing Gemfile is, and install the required gems.

        export BUNDLE_GEMFILE=$PWD/test/support/Gemfile
        bundle install

* Once the above are installed, you should be able to run Test Kitchen:

        bundle exec kitchen list
        bundle exec kitchen test
