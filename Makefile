# Makefile for Flutter Golf Cart Computer
# Protobuf code generation and project utilities

PROTO_DIR := proto
DART_OUT_DIR := lib/data/generated
PROTOC := protoc
DART_PLUGIN := $(shell which protoc-gen-dart 2>/dev/null || echo "$$HOME/.pub-cache/bin/protoc-gen-dart")

.PHONY: all proto clean-proto setup-proto help

all: proto

## Setup protoc-gen-dart plugin
setup-proto:
	@echo "Activating protoc_plugin (protoc-gen-dart) v21.1.2..."
	dart pub global activate protoc_plugin 21.1.2
	@echo "Done. Ensure ~/.pub-cache/bin is in your PATH."

## Generate Dart classes from .proto files
proto: $(DART_OUT_DIR)
	@echo "Generating Dart protobuf classes..."
	$(PROTOC) \
		--proto_path=$(PROTO_DIR) \
		--dart_out=$(DART_OUT_DIR) \
		$(PROTO_DIR)/portnums.proto \
		$(PROTO_DIR)/telemetry.proto \
		$(PROTO_DIR)/config.proto \
		$(PROTO_DIR)/module_config.proto \
		$(PROTO_DIR)/channel.proto \
		$(PROTO_DIR)/admin.proto \
		$(PROTO_DIR)/mesh.proto
	@echo "Protobuf Dart classes generated in $(DART_OUT_DIR)/"

$(DART_OUT_DIR):
	mkdir -p $(DART_OUT_DIR)

## Remove generated protobuf files
clean-proto:
	@echo "Cleaning generated protobuf files..."
	rm -rf $(DART_OUT_DIR)/*.pb*.dart
	@echo "Done."

## Show help
help:
	@echo "Available targets:"
	@echo "  make setup-proto  - Install protoc-gen-dart plugin"
	@echo "  make proto        - Generate Dart classes from .proto files"
	@echo "  make clean-proto  - Remove generated Dart protobuf files"
	@echo "  make help         - Show this help message"
