---
description: Manual only. Convention for documenting root Terraform variables so terraform-docs renders them into terraform.tfvars.example.
---

# Documenting root variables

Applies to `variables.tf` in the repository root only.

## Description format

- Use a heredoc: `description = <<-EOT ... EOT`.
- First line: one-sentence summary of the variable.
- Then one line per field, indented by two spaces: `field.path: explanation`.
- Paths: `<key>` for map keys, `[]` for list elements, `.` for nesting, e.g. `node_groups.<key>.max_size`, `buckets[].name`.
- Prefix fields declared `optional(...)` with `(optional)` and state the default, e.g. `defaults to false`.
- Document every field of every object, including nested ones.
- Keep one field per line; never wrap a field over several lines.
- Never write `${` or `%{` in a description, Terraform would interpolate it.
- Do not change types or defaults when documenting.

## Example

```hcl
description = <<-EOT
  Configuration of the AWS EKS add-on coredns.
    enable: (optional) Deploy the add-on; defaults to true.
    configuration_values: (optional) JSON/YAML add-on configuration.
EOT
```

## After editing

1. `terraform fmt variables.tf`
2. `terraform validate`
3. Regenerate the example (same as CI, no markers):
   `terraform-docs -c tfvars.hcl.terraform-docs.yml --output-file terraform.tfvars.example --output-mode replace --output-template '{{ .Content }}' .`
4. Do not edit `terraform.tfvars.example` by hand.
