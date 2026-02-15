.PHONY: content-index workflow-check install-hooks new-task

content-index:
	@bash tools/content_index.sh

workflow-check:
	@if [ -z "$(TASK_ID)" ]; then echo "Usage: make workflow-check TASK_ID=<task-id>"; exit 1; fi
	@TASK_ID="$(TASK_ID)" bash tools/workflow_check.sh

install-hooks:
	@bash tools/install_hooks.sh

new-task:
	@if [ -z "$(TASK_ID)" ]; then echo "Usage: make new-task TASK_ID=<task-id>"; exit 1; fi
	@bash tools/new_task.sh "$(TASK_ID)"
