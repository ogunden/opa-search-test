.PHONY: clean

SRC = search_test.opa

all: search_test.exe

search_test.exe: $(SRC)
	opa --parser classic $^

clean:
	rm -rf _build _tracks access.log error.log search_test.exe
