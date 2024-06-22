# aws-org-terraform

# Git merge rules

* Only `fast-forward-only` merge mode is supported.

* Only single commit per story/task. So your SINGLE commit in the feature branch HAS TO be always on top of current master HEAD.

* Your commit message has to follow [Semantic Commit Message rules](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716).

Sample artificial git commit:

```bash
git commit -a -m 'feat: add support to phase of the moon'
```

### How to run Terraform

```./bin/terraform.sh``` script is intended to run Terraform consistently.
Based on input arguments it calculates required paths.
There is no need to execute this script from within the 'bin' folder.
Usage exampls:
1. bin/terraform.sh -e dev -c core -a plan [-o dev.core.tfplan]
2. bin/terraform.sh -e dev -c core -a apply [-o dev.core.tfplan]
