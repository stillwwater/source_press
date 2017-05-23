Source Press
============

*source_press* allows you to combine multiple source files into a single file.

It works on any language as long as `.press.yml` is configured correctly.


Installation
============

    $ gem install source_press

## Run with

    $ srcpress


How To
======

1. `cd` to the directory containing your source files
2. Create a .press.yml config file, use `srcpress gen-config` to generate a template file
3. Run source_press from the command-line with `srcpress`
4. That's it, other options and language-specific settings are described in the template `.press.yml` file


Configuring Source Press
========================

In order for *source_press* to work you'll need to provide a few details in a .press.yml file; the only required setting being a list of files or directories to compile.

## Generating a template .press.yml

    $ srcpress gen-config

## Settings

### OutputFile:

Name + extension of compiled file. Can be left as null/blank.

### OverrideOuput:

When set to true, overrides output file if it's already in the directory.

### ImportKeywords:

Language specific file/library import keywords.

    ie:
    Ruby   - 'require', 'require_relative'
    Python - 'import', 'from'
    C/C++  - '#include'

Can be left as null/blank

### FileOrder:

Relative/full path to files in the order
in which they should appear in the compiled file.

If the order is unimportant, please include a path
to the directory/directories containing the files.

Misc Command-line Options
=========================

### Using a config file with a different name

    $ srcpress config=file_name.yml

### Only output errors and warnings

    $ srcpress --silent

### Verify gem version

    $ srcpress -v
