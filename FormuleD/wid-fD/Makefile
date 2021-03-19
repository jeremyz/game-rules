
WDIR="./output"

.SUFFIXES:
.SUFFIXES: .java .class .tdf .json .png

.java.class:
	javac $<

.tdf.json:
	java Tdf2JSON $<

.json.png:
	ruby json2png.rb $<

monaco.png: monaco.jpg monaco.json json2png.rb
monaco.json: monaco.tdf Tdf2JSON.class

clean:
	rm -fr *~ *.class *.json $(WDIR)

