chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
private_key = ../chrome-repl.pem

all: ruby/google-chrome-0.1.gem chrome-repl.crx

ruby/google-chrome-0.1.gem:
	cd ruby && gem build google-chrome.gemspec

chrome-repl.crx:
	$(chrome) --pack-extension=extension --pack-extension-key=$(private_key)
	mv extension.crx $@

clean:
	-rm *~
	-rm */*~
	-rm chrome-repl.crx
	-rm ruby/google-chrome-0.1.gem
