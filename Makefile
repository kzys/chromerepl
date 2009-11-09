chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
private_key = ../chrome-repl.pem

chrome-repl.crx:
	$(chrome) --pack-extension=extension --pack-extension-key=$(private_key)
	mv extension.crx $@

clean:
	-rm *~
	-rm */*~
	-rm extension.pem
	-rm chrome-repl.crx
