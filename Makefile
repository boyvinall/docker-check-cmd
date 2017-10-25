#------------------------------------------------
#
#	setup environment
#
#------------------------------------------------

export GOPATH:=$(realpath $(shell pwd)/../../../..)

#------------------------------------------------
#
#	standard rules
#
#------------------------------------------------

# The first target defined is the default if no target is
# specified on the command line.  Make sure this doesn't
# take too long to run, so that people will run it on every
# build.
.PHONY: fast
fast: build coverage-short lint-fast

# Also define the "full fat" rule that does everything
.PHONY: all build
all: build coverage lint-full

#
#  See https://gopkg.in/make.v4 for a list of
#  versions and http://gopkg.in for more info.
#
GOMAKE:=gopkg.in/make.v4
-include $(GOPATH)/src/$(GOMAKE)/batteries.mk
$(GOPATH)/src/$(GOMAKE)/%:
	go get $(GOMAKE)/...

#------------------------------------------------
#
#	now to actually build stuff...
#
#------------------------------------------------

BASENAME_BINARY:=check-cmd
VERSION:=$(patsubst v%,%,$(shell git describe --tags 2> /dev/null))

GOARCH=amd64
$(DIR_OUT)/windows-% : GOOS=windows
$(DIR_OUT)/darwin-%  : GOOS=darwin
$(DIR_OUT)/linux-%   : GOOS=linux

BUILD_BINARIES:=\
	$(DIR_OUT)/windows-$(GOARCH)/$(BASENAME_BINARY).exe \
	$(DIR_OUT)/darwin-$(GOARCH)/$(BASENAME_BINARY) \
	$(DIR_OUT)/linux-$(GOARCH)/$(BASENAME_BINARY)

build: $(BUILD_BINARIES)

.PHONY: $(BUILD_BINARIES)
$(BUILD_BINARIES): %: vendor
	$(call PROMPT,Building $@)
	GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=0 \
		$(GO) build -ldflags='$(STRIP_DEBUG)' -o $@
	cd $(dir $@) ; zip - $(notdir $@) > ../$(BASENAME_BINARY)_$(VERSION)_$(GOOS)_$(GOARCH).zip

clean::
	rm -f $(BUILD_BINARIES)
