# PHP strict types

This script verifies if each new PHP files has the **declare(strict_types=1);** directive.

If not, it can automatically be added by adding the **--fix** option.

## Usage

```shell
php-strict-types <paths to check> options
# php-strict-types src tests --fix
```

## Options

- `--fix`: Fix the files by adding the directive
- `--check`: Check if the files have the directive (default mode)
- `--help`: Display help
