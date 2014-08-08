# Notifiable Diseases

## Development setup

Run from project folder:

* Install nodejs
* Install globally bower and grunt client `npm install -g bower grunt-cli`
* Install node packages `npm install`
* Install bower packages `bower install`

To install generators as well:

* Install yeoman `npm install -g yo`
* Install generator angular `npm install -g generator-angular`

Ruby and compass are also required dependencies, so run `gem install compass` in the context of a Ruby interpreter.

## Configuration

Application settings are configured in `conf/settings.json`; these settings are merged with the contents of `conf/settings.local.json`, and are further merged with the contens of a file specified as `--settings=PATH` when running `grunt`.

See `conf/settings.json` for a list of available settings and their default values.


