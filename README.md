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

Run the server via `grunt serve`.

## Configuration

Application settings are configured in `conf/settings.json`; these settings are merged with the contents of `conf/settings.local.json`, and are further merged with the contens of a file specified as `--settings=PATH` when running `grunt`.

See `conf/settings.json` for a list of available settings and their default values.


### Map charts

To draw areas in map charts, the application uses [topojson](http://github.com/mbostock/topojson) files with the corresponding polygon information for each administrative level. The URLs where this files are served must be configured in the settings. For example:

```
{
  ...
  "polygons": {
      "0": "/polygons/us_outline.topo.json",
      "1": "/polygons/us_states.topo.json",
      "2": "/polygons/us_counties.topo.json"
    }
}
```

Note that the option to add maps to a report will only be available if this setting is present. Additionally, each topojson feature must contain the **ID** and **PARENT_ID** properties, which map to the location ids returned by the API.
