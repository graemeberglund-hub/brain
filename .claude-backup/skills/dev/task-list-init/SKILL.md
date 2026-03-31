---
name: task-list-init
description: Create comprehensive task list with detailed implementation steps from a PRP or project description
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: "[PRP path or project description]"
---

Create a comprehensive task list in PRPs/checklist.md for implementing $ARGUMENTS

Ingest the information then dig deep into the existing codebase. When done ->

ULTRATHINK about the product task and create the plan based on CLAUDE.md and create detailed tasks following this principle:

### list of tasks to be completed to fullfill the PRP in the order they should be completed using information dense keywords

 - Information dense keyword examples:
 ADD, CREATE, MODIFY, MIRROR, FIND, EXECUTE, KEEP, PRESERVE etc

 Mark done tasks with: STATUS [DONE], if not done leave empty

```yaml
Task 1:
STATUS [ ]
MODIFY src/existing_module.py:
  - FIND pattern: "class OldImplementation"
  - INJECT after line containing "def __init__"
  - PRESERVE existing method signatures

STATUS [ ]
CREATE src/new_feature.py:
  - MIRROR pattern from: src/similar_feature.py
  - MODIFY class name and core logic
  - KEEP error handling pattern identical

...(...)

Task N:
...

```

Each task should have unit test coverage, ensure tests pass on each task
