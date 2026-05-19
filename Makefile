SHELL := /bin/bash

PROJECT := Wrimoire.xcodeproj
SCHEME := Wrimoire
UNIT_TEST_SCHEME := Wrimoire
UI_TEST_SCHEME := Wrimoire-UITests
UI_TEST_DESTINATION ?= platform=iOS Simulator,name=iPhone 17 Pro
DERIVED_DATA_PATH := $(CURDIR)/DerivedData
XCODEBUILD := xcodebuild
CODE_SIGNING_ALLOWED ?= NO

XCBEAUTIFY := $(shell command -v xcbeautify 2>/dev/null)
SWIFTLINT := $(shell command -v swiftlint 2>/dev/null)
ifdef XCBEAUTIFY
XCODEPIPE := | $(XCBEAUTIFY)
else
XCODEPIPE :=
endif

.PHONY: help doctor list-schemes build-macos build-ios-sim lint test test-ui pre-push install-xcbeautify

help:
	@printf "Targets:\n"
	@printf "  make doctor             # Show tool availability and key configuration\n"
	@printf "  make list-schemes       # List Xcode schemes\n"
	@printf "  make build-macos        # Build the app for macOS\n"
	@printf "  make build-ios-sim      # Build the app for a generic iOS Simulator destination\n"
	@printf "  make lint               # Run SwiftLint (must be installed locally)\n"
	@printf "  make test               # Run the macOS unit test suite\n"
	@printf "  make test-ui            # Run the iOS simulator UI test suite\n"
	@printf "  make pre-push           # Run lint + macOS build + unit tests + UI tests\n"
	@printf "  make install-xcbeautify # Install xcbeautify via Homebrew\n"
	@printf "\n"
	@printf "Overrides:\n"
	@printf "  CODE_SIGNING_ALLOWED=YES  # Enable signing for local builds when needed\n"
	@printf "  UI_TEST_DESTINATION=...   # Override the simulator destination for UI tests\n"

doctor:
	@echo "xcodebuild: $$(command -v $(XCODEBUILD) || echo missing)"
	@echo "xcbeautify: $$(command -v xcbeautify || echo missing - output will not be prettified)"
	@echo "swiftlint: $$(command -v swiftlint || echo missing - lint target will fail until installed)"
	@echo "PROJECT: $(PROJECT)"
	@echo "SCHEME: $(SCHEME)"
	@echo "UNIT_TEST_SCHEME: $(UNIT_TEST_SCHEME)"
	@echo "UI_TEST_SCHEME: $(UI_TEST_SCHEME)"
	@echo "UI_TEST_DESTINATION: $(UI_TEST_DESTINATION)"
	@echo "DERIVED_DATA_PATH: $(DERIVED_DATA_PATH)"
	@echo "CODE_SIGNING_ALLOWED: $(CODE_SIGNING_ALLOWED)"

list-schemes:
	@$(XCODEBUILD) -list -project $(PROJECT) $(XCODEPIPE)

build-macos:
	@set -o pipefail; \
	$(XCODEBUILD) -project $(PROJECT) -scheme $(SCHEME) -destination 'platform=macOS,arch=arm64' -derivedDataPath $(DERIVED_DATA_PATH) CODE_SIGNING_ALLOWED=$(CODE_SIGNING_ALLOWED) build $(XCODEPIPE)

build-ios-sim:
	@set -o pipefail; \
	$(XCODEBUILD) -project $(PROJECT) -scheme $(SCHEME) -destination 'generic/platform=iOS Simulator' -derivedDataPath $(DERIVED_DATA_PATH) CODE_SIGNING_ALLOWED=$(CODE_SIGNING_ALLOWED) build $(XCODEPIPE)

lint:
ifndef SWIFTLINT
	$(error swiftlint is not installed. Install via `brew install swiftlint`)
endif
	@$(SWIFTLINT) --no-cache

test:
	@set -o pipefail; \
	$(XCODEBUILD) -project $(PROJECT) -scheme $(UNIT_TEST_SCHEME) -destination 'platform=macOS,arch=arm64' -derivedDataPath $(DERIVED_DATA_PATH) CODE_SIGNING_ALLOWED=$(CODE_SIGNING_ALLOWED) test $(XCODEPIPE)

test-ui:
	@set -o pipefail; \
	$(XCODEBUILD) -project $(PROJECT) -scheme $(UI_TEST_SCHEME) -destination '$(UI_TEST_DESTINATION)' -derivedDataPath $(DERIVED_DATA_PATH) CODE_SIGNING_ALLOWED=$(CODE_SIGNING_ALLOWED) test $(XCODEPIPE)

pre-push: lint build-macos test test-ui

install-xcbeautify:
	@brew install xcbeautify
