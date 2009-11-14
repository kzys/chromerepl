chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
private_key = ../chrome-repl.pem
files = ruby/google-chrome-client-0.1.gem chrome-repl.crx

all: $(files)

ruby/google-chrome-client-0.1.gem:
	cd ruby && gem build google-chrome-client.gemspec

chrome-repl.crx:
	$(chrome) --pack-extension=extension --pack-extension-key=$(private_key)
	mv extension.crx $@

clean:
	-rm *~
	-rm */*~
	-rm $(files)