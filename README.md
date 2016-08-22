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
    job2:
      path: /Users/jslee/tmp
      clean_after: 1209600
      dry_run: false

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

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

