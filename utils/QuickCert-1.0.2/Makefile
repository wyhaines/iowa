RUBY?=ruby

syntax:
	${RUBY} -dcw ./bin/QuickCert ./lib/QuickCert/qc_defaults.rb

test: syntax

install: test
	${RUBY} setup.rb config
	${RUBY} setup.rb setup
	${RUBY} setup.rb install

clean:
	rm -f config.save InstalledFiles

