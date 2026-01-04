.PHONY: all test build distribute pipeline help

ifeq ($(OS),Windows_NT)
    SHELL_EXT := ps1
    RUN_CMD := powershell -ExecutionPolicy Bypass -File
    NOTES_ARG := -ReleaseNotes
    GROUPS_ARG := -Groups
    DRY_RUN_ARG := -DryRun
    DEBUG_ARG := -VerboseOutput
else
    SHELL_EXT := sh
    RUN_CMD := ./
    NOTES_ARG := --release-notes
    GROUPS_ARG := --groups
    DRY_RUN_ARG := --dry-run
    DEBUG_ARG := --debug
endif

help:
	@echo "Available commands:"
	@echo "  make test        - Run all tests"
	@echo "  make build       - Build release APK"
	@echo "  make distribute  - Distribute existing APK to Firebase"
	@echo "  make pipeline    - Run full test, build, and distribute pipeline"
	@echo "  make clean       - Clean build artifacts"

test:
	@$(RUN_CMD) ./scripts/ci_all.$(SHELL_EXT)

build:
	flutter build apk --release

distribute:
	@$(RUN_CMD) ./scripts/distribute-apk.$(SHELL_EXT) $(if $(NOTES),$(NOTES_ARG) "$(NOTES)") $(if $(GROUPS),$(GROUPS_ARG) "$(GROUPS)") $(if $(DRY_RUN),$(DRY_RUN_ARG)) $(if $(DEBUG),$(DEBUG_ARG))

pipeline:
	@$(RUN_CMD) ./scripts/build-and-distribute.$(SHELL_EXT) $(if $(NOTES),$(NOTES_ARG) "$(NOTES)") $(if $(GROUPS),$(GROUPS_ARG) "$(GROUPS)") $(if $(DRY_RUN),$(DRY_RUN_ARG)) $(if $(DEBUG),$(DEBUG_ARG))

clean:
	flutter clean
