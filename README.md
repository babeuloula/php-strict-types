# PHP strict types

This script verifies if each new PHP files has the **declare(strict_types=1);** directive.
If not, it can automatically be added by adding the **--fix** option.

Retrieve the list of new files between the branch previous commit and the current commit.
**Files must be committed when this script is executed.**

## Usage

```shell
php-strict-types options <paths to check>
# php-strict-types --fix src tests
```

## Options

- `--fix`: Fix the files by adding the directive
- `--check`: Check if the files have the directive (default mode)
- `--help`: Display help
