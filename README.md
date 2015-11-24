# Notifiable Diseases

[![Build Status](https://travis-ci.org/instedd/notifiable-diseases.svg?branch=master)](https://travis-ci.org/instedd/notifiable-diseases)

Notifiable diseases is a client-side only dashboard that enables users to create their own reports from a [CDX API](http://dxapi.org/) compatible source.

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


## API

Notifiable diseases makes use of the [query events](http://dxapi.org/#/query-events) endpoint in CDX API, using the [events schema](http://dxapi.org/#/schema) definition to know which fields are available as filtering and grouping options. Optionally, the app can be also configured to use a multi-queries endpoint, which accepts an array of regular CDX queries and returns an array with the responses in the same order; this can be useful for reducing the number of roundtrips to the server.

Routes should be defined as:

```ruby
  get 'cdx/v1/events/schema' => 'cdx_api#fields'
  match 'cdx/v1/events' => 'cdx_api#query_events', only: [:get, :post]
  match 'cdx/v1/events/multi' => 'cdx_api#multi_query_events', only: [:get, :post]
```

Refer to the [CDX API reference implementation](https://github.com/instedd/cdp) for an example. Note that if you are using Ruby with an ElasticSearch backend, the gem [cdx-api-elasticsearch](https://github.com/instedd/cdx-api-elasticsearch) will provide useful methods for easily implementing this API.

### Store

Additionally, notifiable diseases can be configured to store user's saved reports in a backend server. This requires a simple key-value store JSON API with locking to be set up as in the following example:

```ruby
  get 'store/:key' => 'store#get'
  post 'store/:key' => 'store#put'
  delete 'store/:key' => 'store#delete'
```

```ruby
  def get
    key_value = @key_values.find_by_key params[:key]

    if key_value
      render json: {found: true, version: key_value.lock_version, value: key_value.value}
    else
      render json: {found: false}
    end
  end

  def put
    key, lock_version = params.values_at :key, :version
    value = request.raw_post
    key_value = @key_values.where(key: key).first

    if key_value
      key_value.lock_version = lock_version
    else
      key_value = current_user.active_profile.key_values.new key: key
    end

    key_value.value = value
    key_value.save!

    render json: {version: key_value.lock_version, value: key_value.value}
  end

  def delete
    key_value = @key_values.find_by_key params[:key]
    if key_value
      key_value.destroy
      head :ok
    else
      head :not_found
    end
  end
```


## Configuration

Application settings are configured in `conf/settings.json` or the path specified as `--settings=SETTINGS_JSON_PATH`; these settings are merged with the contents of `conf/settings.local.json`.

* `brand` Title to display in the application
* `api` Endpoint to the CDX API
* `useLocalStorage` True to store each user reports in their browser storage, false to use a remote endpoint
* `store` Endpoint to the key-value store used to save user reports (required only if `useLocalStorage` is false)
* `multiQueriesEnabled` True to use bulk queries to CDX API, set to false if the back end does not support this extension
* `polygons` Paths to topojson files with polygons definitions; see _Map charts_ below
* `parentURL` URL where the app is embedded; see _Embedding_ below
* `replaceParentURLHash` Whether to change the parent window's hash to match the app's, so when the user refreshes he/she will stay in the same page.
* `customStyles` Path to an additional SCSS to be appended to the application's, use to customise the app look and feel
* `proxies` Used in development for proxying requests to the back end server

### Overrides

After NNDD is built, settings and styles can be respectively overridden by injecting files `scripts/overrides.js` and `styles/overrides.css`. The latter is any CSS style to be included after the application main stylesheet, while the former needs to adhere to the following format:

```js
window.overrides = {
  brand: "My brand"
  // etc ...
};
```

### Development configuration

A sample development configuration file is included here:

```json
{
  "api": "/cdx/v1",
  "store": "/store",
  "useLocalStorage": false,
  "customStyles": "../conf/custom.local.scss",
  "polygons": {
    "location": {
      "0": "/polygons/countries.topo.json",
      "1": "/polygons/states.topo.json",
      "2": "/polygons/counties.topo.json"
    }
  }
}
```

By default, grunt development server will proxy all requests to `/api` to `localhost:3000`; you can tune this via the `proxy.context`, `proxy.host` and `proxy.port` grunt options.

### Map charts

To draw areas in map charts, the application uses [topojson](http://github.com/mbostock/topojson) files with the corresponding polygon information for each administrative level for each location field. The URLs where these files are served must be configured in the settings. For example:

```json
  "polygons": {
    "laboratory_location": {
      "0": "/polygons/countries.topo.json",
      "1": "/polygons/states.topo.json",
      "2": "/polygons/counties.topo.json"
    },
    "patient_location": {
      "0": "/polygons/countries.topo.json",
      "1": "/polygons/zipcodes.topo.json"
    }
  }
```

Note that the option to add maps to a report will only be available if this setting is present. Additionally, each topojson feature must contain the **ID** and **PARENT_ID** properties, which map to the location ids returned by the API.


### Embedding

Notifiable diseases can be embedded into an existing web application by packaging it using `grunt dist`, copying it to a publicly available location (such as `/public/nndd` in a Rails app), and serving it from an iframe in the parent application.

It is recommended to set `parentURL` to the location where the host web app will serve the iframe, so if a user attempts to access directly the guest dashboard, he/she will be automatically redirected to the host web app. For example, suppose notifiable diseases is placed in `/public/nndd` and the host web app serves an iframe with `source="/public/nndd"` in `/dashboard`, and `parentURL` is set to `/dashboard` in settings. Then, if a user navigates to `/public/nndd` directly, he will be redirected to `/dashboard` automatically.

Note that in the event of an auth failure returned by the server, typically caused by the user session being terminated, notifiable diseases will fire a `reload-on-auth-failure` message that should be captured from the host web app, and should trigger a redirect to the login page.

```javascript
  var reloading = false;
  $(window).on('message', function(event) {
    event = event.originalEvent;
    if (event.origin && isOriginValid(event.origin)) {
      if (event.data == 'reload-on-auth-failed' && !reloading) {
        console.log('Reloading on auth failure message received from iframe');
        window.location.reload();
        reloading = true;
      }
    } else {
      console.error('Ignoring invalid message received', event);
    }
  });
```
