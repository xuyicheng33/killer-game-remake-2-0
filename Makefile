.PHONY: content-index workflow-check repo-structure-check install-hooks new-task migration-draft test

GODOT ?= godot

test:
	@GODOT="$(GODOT)" bash dev/tools/run_gut_tests.sh 120

content-index:
	@bash dev/tools/content_index.sh

workflow-check:
	@if [ -z "$(TASK_ID)" ]; then echo "Usage: make workflow-check TASK_ID=<task-id>"; exit 1; fi
	@TASK_ID="$(TASK_ID)" bash dev/tools/workflow_check.sh

repo-structure-check:
	@bash dev/tools/repo_structure_check.sh

install-hooks:
	@bash dev/tools/install_hooks.sh

new-task:
	@if [ -z "$(TASK_ID)" ]; then echo "Usage: make new-task TASK_ID=<task-id>"; exit 1; fi
	@bash dev/tools/new_task.sh "$(TASK_ID)"

migration-draft:
	@bash dev/tools/restructure_migration_draft.sh
