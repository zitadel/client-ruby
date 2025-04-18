rename-models:
	@find . -name '*.openapi' | while read openapi_file; do \
		dir=$$(dirname "$$openapi_file"); \
		echo "Processing directory: $$dir"; \
		\
		find "$$dir" -type f -name '*.rb' | while read file; do \
			# Extract the first class name (even if nested in modules) \
			class_name=$$(grep -E '^\s*class ' "$$file" | head -n1 | awk '{print $$2}' | cut -d '<' -f1); \
			[ -z "$$class_name" ] && echo "  Skipping $$file: no class found" && continue; \
			\
			# Convert CamelCase to snake_case (FIXED) \
			snake_case=$$(echo "$$class_name" \
        | sed -E 's/([A-Z]+)([A-Z][a-z])/\1_\2/g' \
        | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' \
        | sed -E 's/([A-Z])/_\1/g' \
        | sed -E 's/^_//' \
        | sed -E 's/_+/_/g' \
        | tr A-Z a-z) \
			\
			new_file="$$(dirname "$$file")/$$snake_case.rb"; \
			if [ "$$file" != "$$new_file" ]; then \
				if [ -e "$$new_file" ]; then \
					echo "  Skipping rename $$file → $$new_file: target exists"; \
				else \
					echo "  Renaming $$file → $$new_file"; \
					mv "$$file" "$$new_file"; \
				fi; \
			fi; \
		done; \
	done
