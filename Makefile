SWIFT_BIN=$(shell which swift)
SWIFT_LINT=$(SWIFT_BIN)-lint

SWIFTC=swiftc
COPY=cp
REMOVE=rm

UNAME=$(shell uname)

ifeq ($(UNAME), Darwin)
XCODE=$(shell xcode-select -p)
SDK=$(XCODE)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk
TARGET=x86_64-apple-macosx10.10
SWIFTC=swiftc -target $(TARGET) -sdk $(SDK) -Xlinker -all_load
COPY=sudo cp
REMOVE=sudo rm
endif

BUILD_DIR=.build/debug
LIBS=$(wildcard $(BUILD_DIR)/*.a)
LDFLAGS=$(foreach lib,$(LIBS),-Xlinker $(lib))

.PHONY: all clean build test install uninstall

all: build

clean:
	swift build --clean

build:
	swift build

test: build $(BUILD_DIR)/test_runner
	./$(BUILD_DIR)/test_runner

$(BUILD_DIR)/test_runner: Tests/*.swift Tests/rule/*.swift Tests/reporter/*.swift $(BUILD_DIR)/lint.a
	$(SWIFTC) -o $@ Tests/*.swift Tests/rule/*.swift Tests/reporter/*.swift -I$(BUILD_DIR) -Xlinker $(BUILD_DIR)/Spectre.a $(LDFLAGS)

install:
	$(COPY) $(BUILD_DIR)/swift-lint $(SWIFT_LINT)

uninstall:
	$(REMOVE) $(SWIFT_LINT)
