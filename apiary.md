FORMAT: 1A
HOST: https://api.arrayofthings.org/api

# Array of Things HTTP API

Welcome to the Array of Things API docs!

The Array of Things is an experimental urban sensing project. More information
about the project can be found at [arrayofthings.org](https://arrayofthings.org/).

## System Structure

AoT is deployed across several geographic areas. These deployment regions are
referred to as **Projects**. For example, our largest deployment is in the city
of Chicago so we have a project named `Chicago`.

The physical devices being deployed are **Nodes**. Networks are comprised of Nodes.
Nodes are identified by their _VSN_ (a unique serial number we assign to each).

Onboard the Nodes are **Sensors**. Sensors observe various facets of the environment,
such as temperature, humidity, light intensity, particulant matter, and other
topics. It is important to note that there can be, and in some cases almost
always is, redundancy in the types of information sensors record. It is important
to read the [sensor data sheets](https://github.com/waggle-sensor/sensors/tree/master/sensors/datasheets)
provided by the Waggle team to determine differences.

The information recorded by Sensors are **Observations**. Observations are snapshots
of measurements at a given time on a given Node. It is important to note that some
Sensors are still not fully tuned or are in early stages of experimentation, and by
virtue of that their Observations may not have fully accurate data. To help disambiguate
these situations, the API also provides **Raw Observations** with both the raw value
of the observation and the _clean_ or _human readable_ value.

So, you can think of the hierarchy of system entities in the following sentence:

**Observations** are _recorded by_ **Sensors** that are _onboard_ **Nodes** that _organized within_ **Projects**.

## API Endpoints

The entire API is namespaced under the `/api` route. Each of the entities listed has its own
endpoint. There are many shared query parameters between them and each has a unique set
of parameters that can be optionally applied.

The corresponding endpoints are:

- Projects are listed at `/projects` and details are found at `/projects/:slug`
- Nodes are listed at `/nodes` and details are found at `/nodes/:vsn`
- Sensors are listed at `/sensors` and details are found at `/sensors/:path`
- Observations are listed at `/observations` (there is no detail path)
- Raw Observations are listed at `/raw-observations` (there is no detail path)

## Universal Query Params

The following table lists query parameters that can be applied to every endpoint.

| Parameter Key | Value Information                     | Example           | Details                                                                                                           |
| ------------- | ------------------------------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------- |
| order         | A direction and an attribute name     | `desc:timestamp`  | The ordering applied to the results; formatted as `asc|desc:{attribute}`; each endpoint provides a unique default |
| page          | A positive integer                    | `1` or `200`      | Used with the _size_ parameter to page through list endpoint results; default is `1`                              |
| size          | A positive integer not exceeding 5,00 | `20` or `1000`    | Used with the _page_ parameter to page through list endpoint results; default is `200`                            |

**NOTE:** there are some specific params that perform aggregates and _do not_ allow
for `order`, `size` and `page` query params. These params are:

- `histogram` formatting parama on the **/observations** endpoint
- `time_bucket` formatting parama on the **/observations** endpoint

These parameters default to ordering the results by time group in ascending order, with
the full result set provided in one page. All other parameters can be applied.

# API Details and Examples

## Project Endpoint [/projects{?order,page,size,format}]

### List the Projects [GET]

+ Parameters
  + order (string, optional)
      Orders the response objects
      + Default: "asc:name"
  + page (integer, optional)
      Specifies which page of results is returned
      Default: 1
  + size (integer, optional)
      Specifies the maximum number of objects in the result
      Default: 200
  + format (string, optional)
      Specifies the format of the response. Can either be "json" or "geojson".
      Default: "json"

## Node Endpoint [/nodes{?order,page,size,format,with_sensors,project,location}]

### Filtering Using the LOCATION Param

Nodes can be filtered using their `location` attribute. There are two
forms this filter can take:

1. Finding nodes within a given geometry using the `within` function
2. Finding nodes within a given distance from a given point using the `dwithin` function

#### Within a Geometry

For this option, the results are filtered to those that are within a
given geometry -- typically a Polygon. The parameter is formatted as:

```
?location=within:{
  "type": "Feature",
  "geometry": {
    "type": "Polygon",
    "coordinates": [[
      [1, 1],
      [1, 2],
      [2, 2],
      [2, 1],
      [1, 1]
    ]],
    "crs": {
      "type": "name",
      "properties": {
        "name": "EPSG:4326"
      }
    }
  }
}
```

#### Within Distance from Point

For this option, the results are filtered to those that are within
a given distance **in meters** from a given point. The parameter is
formatted as:

```
?location=dwithin:2000::{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [12.234,-23.456],
    "crs": {
      "type": "name",
      "properties": {
        "name": "EPSG:4326"
      }
    }
  }
}
```

or in shorthand: `dwithin:{{ distance in meters }}::{{ point }}`.

### List the Nodes [GET]

+ Parameters
  + order (string, optional)
      Orders the response objects
      + Default: "asc:vsn"
  + page (integer, optional)
      Specifies which page of results is returned
      Default: 1
  + size (integer, optional)
      Specifies the maximum number of objects in the result
      Default: 200
  + format (string, optional)
      Specifies the format of the response. Can either be "json" or "geojson".
      Default: "json"
  + with_sensors (boolean, optional)
      Embeds the related sensors into the body.
  + project (string, optional)
      Filters the results to only those who have a relationship to the given project. To use, set value as Project Slugs.
  + location (object, optional)
      Filters the results to only those whose location is within or within distance from the filter geometry value.

## Sensor Endpoint [/sensors{?order,page,size}]

### List the Sensors [GET]

+ Parameters
  + order (string, optional)
      Orders the response objects
      + Default: "asc:vsn"
  + page (integer, optional)
      Specifies which page of results is returned
      Default: 1
  + size (integer, optional)
      Specifies the maximum number of objects in the result
      Default: 200

## Observations Endpoint [/observations{?order,page,size,project,node,sensor,location,timestamp,value,histogram,time_bucket}]

### Applying Aggregation

The observation values can be summarized and aggregated using a
special parameter format on the `value` key. The format must
follow the format `{{ func }}:{{ grouping field }}`.

Grouping fields:

- `node_vsn`
- `sensor_path`

### Filtering by Timestamp and Location

Filtering using the `timestamp` attribute adheres to the same rules
as the timestamp filters for nodes.

Filtering against the related node's location attribute is also possible
using the same filtering scheme listed for nodes.

### List the Observations [GET]

+ Parameters
  + order (string, optional)
      Orders the response objects
      + Default: "asc:vsn"
  + page (integer, optional)
      Specifies which page of results is returned
      Default: 1
  + size (integer, optional)
      Specifies the maximum number of objects in the result
      Default: 200
  + project (string, optional)
      Filters the results to only those who have a relationship to the given project. To use, set value as a Project Slug.
  + node (string, optional)
      Filters the results to only those who have a relationship to the given node. To use, set value as a Node VSN.
  + sensor (string, optional)
      Filters the results to only those who have a relationship to the given sensor. To use, set value as a Sensor Path.
  + location (object, optional)
      Filters the results to only those whose location is within or within distance from the filter geometry value.
  + timestamp (string, optional)
      Filters the results to only those whose `timestamp` attribute satisfies the query.
  + value (string, optional)
      Filters the results to only those whose `value` attribute satisfies the query.
  + histogram (string, optional)
      Computes a histogram for the observations.
  + time_bucket (string, optional)
      Computes aggregates for the observations partitioned by equally sized time frames.
