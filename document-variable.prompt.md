---
description: Add or extend a root Terraform variable with per-field descriptions and regenerate terraform.tfvars.example.
agent: agent
---

Follow [the variable documentation convention](./tfvars-variable-docs.instructions.md).

Task: ${input:task:Describe the variable to add or extend, e.g. "add variable foo with fields a, b, c"}

Apply the change in `variables.tf`, document every field, then run the format, validate and regenerate steps from the convention and report the result.
