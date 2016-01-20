BIN_NAME:=check-cmd

# export GOPATH:=$(shell godep path):$(GOPATH)

all: goupx binary

goupx:
	@if [ -z "$$(which goupx 2> /dev/null)" ]; then \
		echo Installing goupx ...;\
		go get github.com/pwaller/goupx ;\
	fi

clean:
	rm -f $(BIN_NAME)

binary: $(BIN_NAME)

$(BIN_NAME): *.go
	CGO_ENABLED=0 go build -ldflags "-s" -a -installsuffix cgo -ldflags "-w" -o $@ .
	goupx $(BIN_NAME)

TEST_PORT:=1234

test: $(BIN_NAME)
	-docker rm -f test_container 2>/dev/null
	docker build -t test .
	docker run -d --name=test_container test
	./$(BIN_NAME) test_container $(TEST_PORT) /print.sh

.PHONY : all clean binary test goupx
