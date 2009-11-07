chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

chrome-repl.crx:
	$(chrome) --pack-extension=extension
	mv extension.crx $@

clean:
	-rm *~
	-rm */*~
	-rm extension.pem
	-rm chrome-repl.crx
