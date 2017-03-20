# Nightman

Very uncomplicated tool for scheduled cleanups of files according to last-modified time.

## Installation

    $ gem install nightman

## Example configuration

    ---
    downloads:
      path: /Users/jslee/Downloads
      clean_after: 604800
      dry_run: true
      include_match:
        - '\.(pdf|jpg|png|iso)$'
      exclude_match:
        - '^install[0-9][0-9].iso$'
    job2:
      path: /Users/jslee/tmp
      clean_after: 1209600
      dry_run: false

The above `downloads` job configuration illustrates the usage of include and
exclude match rules.

The `include_match` and `exclude_match` rules are applied only to candidate
files considered old enough to delete, and are evaluated as follows:

* each rule is a single regular expression

* exclude rules override include rules

* if only include rules are specified, candidates that do not match will be
  preserved

* if only exclude rules are specified, candidates that do not match will be
  deleted

* if no rules are specified, all candidates will be deleted

Any number of jobs can be configured. They must all have unique names.

## Configuration caveats

* `dry_run` defaults to `true`

* `clean_after` specifies (in seconds) how far in the past a file's
modification time must be in order to be a deletion candidate.

* if `clean_after` is not specified, or is less than a week (!!), the job will
be run as if `dry_run` was set to `true`, even if it was explicitly configured
to `false`

## Usage

    nightman cleanup --config /path/to/config_file.yaml

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fairfaxmedia/nightman.

## License

The gem is available as open source under the terms of the [Apache-2.0 License](http://opensource.org/licenses/Apache-2.0).

