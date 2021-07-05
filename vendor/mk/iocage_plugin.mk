CLI_INSTALL_SRC_URL := https://fnichol.github.io/iocage-plugin-cli/install.sh
VENDORED_CLI := overlay/usr/local/bin/plugin

vendor-cli: ## Vendors the current version of the iocage-plugin-cli
	fetch -o - $(CLI_INSTALL_SRC_URL) \
		| sh -s -- --destination=$$(dirname $(VENDORED_CLI)) \
		&& $(VENDORED_CLI) --version \
		&& echo "--- New version of iocage-plugin-cli is vendored in $(VENDORED_CLI)"
.PHONY: vendor-cli
