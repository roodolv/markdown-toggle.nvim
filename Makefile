.PHONY: test
test: tests/deps/mini.nvim
	@echo "Running all tests..."
	@for dir in marks features shared; do \
		if [ -d "tests/$$dir" ]; then \
			for file in tests/$$dir/*_spec.lua; do \
				[ -f "$$file" ] || continue; \
				echo "Testing $$file..."; \
				nvim --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run_file('$$file')" 2>&1 | grep -E "(Total|Fails|tests)"; \
			done; \
		fi; \
	done

.PHONY: test-file
test-file: tests/deps/mini.nvim
	nvim --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"

tests/deps/mini.nvim:
	@echo "Installing mini.nvim for testing..."
	@mkdir -p tests/deps
	git clone --depth 1 https://github.com/echasnovski/mini.nvim tests/deps/mini.nvim

.PHONY: clean-deps
clean-deps:
	rm -rf tests/deps
