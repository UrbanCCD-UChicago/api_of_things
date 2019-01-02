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

## Entity Schemas

For each of the entities above, these are their schema details.

### Project

| Attribute           | Type      | Details             | Description                                                                                                       |
| ------------------- | --------- | ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| name                | Text      | Unique              | The name of the project                                                                                           |
| slug                | Text      | Unique, Primary Key | The downcased, URI compliant version of the name: e.g. `Chicago` becomes `chicago`; `New York` becomes `new-york` |
| first_observation   | Timestamp |                     | The first recorded observation within the project -- essentially its birthday                                     |
| latest_observation  | Timestamp |                     | The latest recorded observation within the project                                                                |
| bbox                | Geometry  |                     | A polygon that gives the south-western-most and north-eastern-most coordinates of nodes within the project        |
| hull                | Geometry  |                     | A polygon that gives the exact convex hull (outline) of the nodes within the project                              |

### Node

| Attribute           | Type      | Details             | Description                                                                                                       |
| ------------------- | --------- | ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| vsn                 | Text      | Unique, Primary Key | The unique identifier of the node                                                                                 |
| location            | Geometry  |                     | The geographic point of the nodes (longitude, latitude)                                                           |
| description         | Text      |                     | General information about the node                                                                                |
| human_address       | Text      |                     | A street address for the node -- something recognizable by humans                                                 |
| commissioned_on     | Timestamp |                     | The burn-in date of the node's firmware -- essentially its birthday                                               |
| decommissioned_on   | Timestamp |                     | The timestamp the node was taken offline                                                                          |

### Sensor

| Attribute           | Type      | Details             | Description                                                                                                       |
| ------------------- | --------- | ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| path                | Text      | Unique, Primary Key | The unique identifier of the sensor -- the dotted concatenation of the subsystem, sensor and path                 |
| subsystem           | Text      |                     | The physical or logical board of sensors on which this sensor is placed                                           |
| sensor              | Text      |                     | The name of the specific sensor                                                                                   |
| parameter           | Text      |                     | What the sensor is measuring; e.g. temperature, humidity, gas concentration, etc.                                 |
| ontology            | Text      |                     | A hierarchical category for the sensor                                                                            |
| uom                 | Text      |                     | The unit of measurement; e.g. `C` for celcius                                                                     |
| min                 | Float     |                     | The minimum _good_ value for an observation made by this sensor                                                   |
| max                 | Float     |                     | The maximum _good_ value for an observation made by this sensor                                                   |
| data_sheet          | Text      |                     | A link to a detailed spec sheet for the sensor                                                                    |

### Observation

| Attribute           | Type      | Details             | Description                                                                                                       |
| ------------------- | --------- | ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| node_vsn            | Text      | Foreign Key         | The `vsn` of the node that made the observation                                                                   |
| sensor_path         | Text      | Foreign Key         | The `path` of the sensor that made the observation                                                                |
| timestamp           | Timestamp |                     | The timestamp of when the observation was recorded                                                                |
| value               | Float     |                     | The parsed value of the observation -- essentially a hueristically verified _good_ value                          |

### Raw Observation

| Attribute           | Type      | Details             | Description                                                                                                       |
| ------------------- | --------- | ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| node_vsn            | Text      | Foreign Key         | The `vsn` of the node that made the observation                                                                   |
| sensor_path         | Text      | Foreign Key         | The `path` of the sensor that made the observation                                                                |
| timestamp           | Timestamp |                     | The timestamp of when the observation was recorded                                                                |
| hrf                 | Float     |                     | The parsed value of the observation -- essentially a hueristically verified _good_ value                          |
| raw                 | Float     |                     | The raw value of the observation -- essentially an unverified analug reading from a sensor                        |

### Many to Many Relationships

There are obvious one to many relationships between nodes and raw/observations, and sensors and 
raw/observations. But there are also many to many relationships between projects, nodes and
sensors:

- Projects and Nodes share a relationship (it's how we calculate the bbox and hull for the project)
- Projects and Sensors share a relationship (sensors are onboard nodes and can be linked back)
- Nodes and Sensors share a relationship (via observations)

The obvious nature of the M2Ms between nodes and sensors and projects and sensors is intuitive.
However, we cannot guarantee that a node cannot be included in multiple projects. Let's say
for example that we had a special deployment of nodes to observe some small region within the city
of Chicago (where we already have an established project). We may decide that we want a logical
separation for this cluster of nodes in its own project, but by virtue of being in the same 
region as the Chicago project it would make sense to include those there. Hence the many to
many relationship.

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

- `as_histogram`
- `as_time_buckets`

These parameters default to ordering the results by time group in ascending order, with
the full result set provided in one page. All other parameters can be applied.

# API Details and Examples

## Project Endpoint [/projects{?order,page,size,format,include_nodes,include_sensors,has_node,has_nodes,has_nodes_exact,has_sensor,has_sensors,has_sensors_exact,bbox}]

### Filtering Using the BBOX Param

Projects can be filtered using their `bbox` attribute. The filter must be 
constructed as `function:geojson` where _function_ is either **intersects**
or **contains**; _geojson_ must be a URL encoded GeoJSON object.

Here's an example of filtering projects who contain a specific point:

```
?bbox=contains:{
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

Here's an example of filtering project who intersect a polygon:

```
?bbox=intersects:{
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
  + include_nodes (string, optional)
      Should the related nodes be embedded for each object? To use, set to "true"
  + include_sensors (string, optional)
      Should the related sensors be embedded for each object? To use, set to "true"
  + has_node (string, optional)
      Filters the results to only those who have a relationship to the given node. To use, set value as a Node VSN.
  + has_nodes (string, optional)
      Filters the results to only those who have a relationship to any of the given nodes. To use, set value as Node VSNs.
  + has_nodes_exact (string, optional)
      Filters the results to only those who have a relationship to all of the given nodes. To use, set value as Node VSNs.
  + has_sensor (string, optional)
      Filters the results to only those who have a relationship to the given sensor. To use, set value as a Sensor Path.
  + has_sensors (string, optional)
      Filters the results to only those who have a relationship to any of the given sensors. To use, set value as Sensor Paths.
  + has_sensors_exact (string, optional)
      Filters the results to only those who have a relationship to all of the given sensors. To use, set value as Sensor Paths.
  + bbox (object, optional)
      Filters the results to only those whose bbox intersects or contains the filter geometry value.

+ Response 200 (application/json)

{
  "data": [
    {
      "slug": "chicago",
      "name": "Chicago",
      "latest_observation": "2018-10-19T11:37:43",
      "hull": {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "crs": {
            "type": "name",
            "properties": {
              "name": "EPSG:4326"
            }
          },
          "coordinates": [[
            [ -87.539374, 41.666078 ],
            [ -87.982901, 41.718008 ],
            [ -87.76257, 41.96759 ],
            [ -87.655523, 41.994597 ],
            [ -87.54045, 41.741148 ],
            [ -87.536509, 41.713867 ],
            [ -87.539374, 41.666078 ]
          ]]
        }
      },
      "first_observation": "2017-01-01T00:00:00",
      "bbox": {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "crs": {
            "type": "name",
            "properties": {
              "name": "EPSG:4326"
            }
          },
          "coordinates": [[
            [ -87.982901, 41.666078 ],
            [ -87.982901, 41.994597 ],
            [ -87.536509, 41.994597 ],
            [ -87.536509, 41.666078 ],
            [ -87.982901, 41.666078 ]
          ]]
        }
      },
      "archive_url": "http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.latest.tar"
    }
  ]
}

### Format Response as GeoJSON [GET]

+ Parameters
  + format (string, optional)
      Specifies the format of the response. Can either be "json" or "geojson".
      Default: "geojson"

+ Response 200 (application/json)

{
  "data":[
    {
      "type":"Feature",
      "properties":{
        "slug":"chicago",
        "name":"Chicago",
        "latest_observation":"2018-10-19T11:57:43",
        "first_observation":"2017-01-01T00:00:00",
        "archive_url":"http://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.latest.tar"
      },
      "geometry":{
        "type":"Feature",
        "geometry":{
          "type":"Polygon",
          "crs":{
            "type":"name",
            "properties":{
              "name":"EPSG:4326"
            }
          },
          "coordinates":[[
            [ -87.539374, 41.666078 ],
            [ -87.982901, 41.718008 ],
            [ -87.76257, 41.96759 ],
            [ -87.655523, 41.994597 ],
            [ -87.54045, 41.741148 ],
            [ -87.536509, 41.713867 ],
            [ -87.539374, 41.666078 ]
          ]]
        }
      }
    }
  ]
}

## Node Endpoint [/nodes{?order,page,size,format,include_projects,include_sensors,assert_alive,assert_dead,within_project,within_projects,within_projects_exact,has_sensor,has_sensors,has_sensors_exact,commissioned_on,decommissioned_on,location}]

### Filtering Using the LOCATION Param

Nodes can be filtered using their `location` attribute. There are two
forms this filter can take:

1. Finding nodes within a given geometry
2. Finding nodes within a given distance from a given point

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
?location=within_distance:2000:{
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

or in shorthand: `within_distance:{{ distance in meters }}:{{ point }}`.

### Filtering Using Timestamps

For the `commissioned_on` and `decommissioned_on` attributes, you can
filter the values using simple arithmatic functions and a timestamp.
The timestamps must be ISO 8601 formatted with a `T` separating the
date and time sections: e.g. `2018-01-01T00:00:00`.

| Operator          | Symbol  | Parameter           |
| ----------------- | ------- | ------------------- |
| Less Than         | <       | `lt:{{ timestamp }}`  |
| Less or Equal     | <=      | `le:{{ timestamp }}`  |
| Equal             | ==      | `eq:{{ timestamp }}`  |
| Greater or Equal  | >=      | `ge:{{ timestamp }}`  |
| Greater Than      | >       | `gt:{{ timestamp }}`  |

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
  + include_projects (string, optional)
      Should the related projects be embedded for each object? To use, set to "true"
  + include_sensors (string, optional)
      Should the related sensors be embedded for each object? To use, set to "true"
  + assert_alive (string, optional)
      Filters the results to only those who do not have a set `decommissioned_on` attribute.
  + assert_dead (string, optional)
      Filters the results to only those who do have a set `decommissioned_on` attribute.
  + within_project (string, optional)
      Filters the results to only those who have a relationship to the given project. To use, set value as a Project Slug.
  + within_projects (string, optional)
      Filters the results to only those who have a relationship to any of the given projects. To use, set value as Project Slugs.
  + within_projects_exact (string, optional)
      Filters the results to only those who have a relationship to all of the given projects. To use, set value as Project Slugs.
  + has_sensor (string, optional)
      Filters the results to only those who have a relationship to the given sensor. To use, set value as a Sensor Path.
  + has_sensors (string, optional)
      Filters the results to only those who have a relationship to any of the given sensors. To use, set value as Sensor Paths.
  + has_sensors_exact (string, optional)
      Filters the results to only those who have a relationship to all of the given sensors. To use, set value as Sensor Paths.
  + commissioned_on (string, optional)
      Filters the results to only those whose `commissioned_on` attribute satisfies the query.
  + decommissioned_on (string, optional)
      Filters the results to only those whose `decommissioned_on` attribute satisfies the query.
  + location (object, optional)
      Filters the results to only those whose location is within or within distance from the filter geometry value.

+ Response 200 (application/json)

{
  "data": [
    {
      "vsn": "090B",
      "location": {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "crs": {
            "type": "name",
            "properties": {
              "name": "EPSG:4326"
            }
          },
          "coordinates": [-87.666406, 41.916586]
        }
      },
      "description": "AoT Chicago (S) [C]",
      "decommissioned_on": null,
      "commissioned_on": "2018-01-01T00:00:00",
      "address": "Elston and Cortland Chicago IL"
    },
    {
      "vsn": "076",
      "location": {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "crs": {
            "type": "name",
            "properties": {
              "name": "EPSG:4326"
            }
          },
          "coordinates": [-87.645248, 41.954825]
        }
      },
      "description": "AoT Chicago (S) [C]",
      "decommissioned_on": "2018-06-04T00:00:00",
      "commissioned_on": "2018-01-01T00:00:00",
      "address": "Lake Shore Drive & Irving Park Rd Chicago IL"
    }
  ]
}

### Format Response as GeoJSON [GET]

+ Parameters
  + format (string, optional)
      Specifies the format of the response. Can either be "json" or "geojson".
      Default: "geojson"

+ Response 200 (application/json)

{
  "data": [
    {
      "type": "Feature",
      "properties": {
        "vsn": "090B",
        "description": "AoT Chicago (S) [C]",
        "decommissioned_on": null,
        "commissioned_on": "2018-01-01T00:00:00",
        "address": "Elston and Cortland Chicago IL"
      },
      "geometry": {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "crs": {
            "type": "name",
            "properties": {
              "name": "EPSG:4326"
            }
          },
          "coordinates": [-87.666406, 41.916586]
        }
      }
    },
    {
      "type": "Feature",
      "properties": {
        "vsn": "076",
        "description": "AoT Chicago (S) [C]",
        "decommissioned_on": "2018-06-04T00:00:00",
        "commissioned_on": "2018-01-01T00:00:00",
        "address": "Lake Shore Drive & Irving Park Rd Chicago IL"
      },
      "geometry": {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "crs": {
            "type": "name",
            "properties": {
              "name": "EPSG:4326"
            }
          },
          "coordinates": [-87.645248, 41.954825]
        }
      }
    }
  ]
}

## Sensor Endpoint [/sensors{?order,page,size,include_projects,include_nodes,observes_project,observes_projects,observes_projects_exact,onboard_node,onboard_nodes,onboard_nodes_exact,ontology}]

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
  + format (string, optional)
      Specifies the format of the response. Can either be "json" or "geojson".
      Default: "json"
  + include_projects (string, optional)
      Should the related projects be embedded for each object? To use, set to "true"
  + include_nodes (string, optional)
      Should the related nodes be embedded for each object? To use, set to "true"
  + observes_project (string, optional)
      Filters the results to only those who have a relationship to the given project. To use, set value as a Project Slug.
  + observes_projects (string, optional)
      Filters the results to only those who have a relationship to any of the given projects. To use, set value as Project Slugs.
  + observes_projects_exact (string, optional)
      Filters the results to only those who have a relationship to all of the given projects. To use, set value as Project Slugs.
  + onboard_node (string, optional)
      Filters the results to only those who have a relationship to the given node. To use, set value as a Node VSN.
  + onboard_nodes (string, optional)
      Filters the results to only those who have a relationship to any of the given nodes. To use, set value as Node VSNs.
  + onboard_nodes_exact (string, optional)
      Filters the results to only those who have a relationship to all of the given nodes. To use, set value as Node VSNs.
  + ontology (string, optional)
      Filters the results to only those whose ontology attribute either exactly matches or prefix matches the value.

+ Response 200 (application/json)

{
  "data": [
    {
      "uom": "counts",
      "subsystem": "alphasense",
      "sensor": "opc_n2",
      "path": "alphasense.opc_n2.bins",
      "parameter": "bins",
      "ontology": "/sensing/air_quality/particulates/particle_count",
      "min": 0.0,
      "max": null,
      "data_sheet": "https://github.com/waggle-sensor/sensors/blob/master/sensors/opc/opcN2.pdf"
    },
    {
      "uom": null,
      "subsystem": "alphasense",
      "sensor": "opc_n2",
      "path": "alphasense.opc_n2.fw",
      "parameter": "fw",
      "ontology": "/system/other/id",
      "min": null,
      "max": null,
      "data_sheet": "https://github.com/waggle-sensor/sensors/blob/master/sensors/opc/opcN2.pdf"
    }
  ]
}

## Observations Endpoint [/observations{?order,page,size,embed_node,embed_sensor,of_project,of_projects,from_node,from_nodes,by_sensor,by_sensors,location,timestamp,value,as_histogram,as_time_buckets}]

### Applying Aggregation

The observation values can be summarized and aggregated using a
special parameter format on the `value` key. The format must
follow the format `{{ func }}:{{ grouping field }}`.

Grouping fields:

- `node_vsn`
- `sensor_path`

Aggregate functions:

- `first` gets the latest observation
- `last` gets the oldest observation
- `count`, `min`, `max`, `avg`, `sum`, `stddev`, `variance` and `percentile` all do exactly what the name implies

#### Caveats

`first` and `last` do not require passing a grouping field. You can use
them simply as `?value=first`.

`percentile` requires you pass an additional value specifying what percentile
you want calculated: `?value=percentile:0.5:node_vsn` for example.

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
  + embed_node (string, optional)
      Should the related node be embedded for each object? To use, set to "true"
  + embed_sensor (string, optional)
      Should the related sensor be embedded for each object? To use, set to "true"
  + of_project (string, optional)
      Filters the results to only those who have a relationship to the given project. To use, set value as a Project Slug.
  + of_projects (string, optional)
      Filters the results to only those who have a relationship to the given project. To use, set value as a Project Slug.
  + from_node (string, optional)
      Filters the results to only those who have a relationship to the given node. To use, set value as a Node VSN.
  + from_nodes (string, optional)
      Filters the results to only those who have a relationship to the given node. To use, set value as a Node VSN.
  + by_sensor (string, optional)
      Filters the results to only those who have a relationship to the given sensor. To use, set value as a Sensor Path.
  + by_sensors (string, optional)
      Filters the results to only those who have a relationship to the given sensor. To use, set value as a Sensor Path.
  + location (object, optional)
      Filters the results to only those whose location is within or within distance from the filter geometry value.
  + timestamp (string, optional)
      Filters the results to only those whose `timestamp` attribute satisfies the query.
  + value (string, optional)
      Filters the results to only those whose `value` attribute satisfies the query.
  + as_histogram (string, optional)
      Computes a histogram for the observations.
  + as_time_buckets (string, optional)
      Computes aggregates for the observations partitioned by equally sized time frames.

+ Response 200 (application/json)

{
  "data": [
    {
      "value": 202776.0,
      "timestamp": "2018-10-19T18:40:36",
      "sensor_path": "ep.mem.free",
      "node_vsn": "025"
    },
    {
      "value": 2038608.0,
      "timestamp": "2018-10-19T18:40:36",
      "sensor_path": "ep.mem.total",
      "node_vsn": "025"
    },
    {
      "value": 637740.0,
      "timestamp": "2018-10-19T18:40:36",
      "sensor_path": "ep.uptime.idletime",
      "node_vsn": "025"
    },
    {
      "value": 94082.0,
      "timestamp": "2018-10-19T18:40:36",
      "sensor_path": "ep.uptime.uptime",
      "node_vsn": "025"
    },
    {
      "value": 92832.0,
      "timestamp": "2018-10-19T18:40:36",
      "sensor_path": "nc.mem.free",
      "node_vsn": "025"
    }
  ]
}

### Aggregate with a Histogram [GET]

+ Parameters
  + by_sensor (string, optional)
      Default: "wagman.htu21d.temperature"
  + as_histogram (string, optional)
      Format the value as `{{ min }}:{{ max }}:{{ grouping field }}`
      Default: "20:30:5:node_vsn"

+ Response 200 (application/json)

{
  "data": [
    {
      "histogram": [
        0,
        1,
        0,
        0,
        0,
        0,
        0
      ],
      "group": "025"
    },
    {
      "histogram": [
        0,
        0,
        0,
        1,
        0,
        0,
        0
      ],
      "group": "006"
    },
    {
      "histogram": [
        0,
        0,
        1,
        0,
        0,
        0,
        0
      ],
      "group": "00D"
    }
  ]
}

### Aggregate to Time Buckets [GET]

+ Parameters
  + by_sensor (string, optional)
      Default: "wagman.htu21d.temperature"
  + as_time_buckets (string, optional)
      Format the value as `{{ aggregate func }}:{{ interval }}`
      Default: "avg:1 hour"

+ Response 200 (application/json)

{
  "data": [
    {
      "bucket": "2018-10-18T22:00:00.000000",
      "avg": 27.43243243243243
    },
    {
      "bucket": "2018-10-18T23:00:00.000000",
      "avg": 26.464285714285715
    },
    {
      "bucket": "2018-10-19T00:00:00.000000",
      "avg": 25.134146341463413
    },
    {
      "bucket": "2018-10-19T01:00:00.000000",
      "avg": 24.036585365853657
    },
    {
      "bucket": "2018-10-19T02:00:00.000000",
      "avg": 23.03614457831325
    },
    {
      "bucket": "2018-10-19T03:00:00.000000",
      "avg": 22.170731707317074
    },
    {
      "bucket": "2018-10-19T04:00:00.000000",
      "avg": 21.428571428571427
    },
    {
      "bucket": "2018-10-19T05:00:00.000000",
      "avg": 21.571428571428573
    },
    {
      "bucket": "2018-10-19T09:00:00.000000",
      "avg": 19.0
    },
    {
      "bucket": "2018-10-19T10:00:00.000000",
      "avg": 19.83783783783784
    },
    {
      "bucket": "2018-10-19T11:00:00.000000",
      "avg": 20.654545454545456
    },
    {
      "bucket": "2018-10-19T12:00:00.000000",
      "avg": 20.666666666666668
    },
    {
      "bucket": "2018-10-19T13:00:00.000000",
      "avg": 20.924242424242426
    },
    {
      "bucket": "2018-10-19T14:00:00.000000",
      "avg": 21.05128205128205
    },
    {
      "bucket": "2018-10-19T15:00:00.000000",
      "avg": 22.180722891566266
    },
    {
      "bucket": "2018-10-19T16:00:00.000000",
      "avg": 22.63855421686747
    },
    {
      "bucket": "2018-10-19T17:00:00.000000",
      "avg": 22.20731707317073
    },
    {
      "bucket": "2018-10-19T18:00:00.000000",
      "avg": 21.558441558441558
    }
  ]
}

## Raw Observations  [/raw-observations{?order,page,size,embed_node,embed_sensor,of_project,of_projects,from_node,from_nodes,by_sensor,by_sensors,location,timestamp,hrf,raw,aggregates,as_histogram,as_time_buckets}]

Raw observations have the exact same query parameters
as regular observations with the exception that you 
can filter by either `hrf` for the good value or `raw`
for the analog value. Also aggregating is split
into its own parameter -- it will compute the named
aggregate for both HRF and raw values.

### List the Raw Observations [GET]

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
  + embed_node (string, optional)
      Should the related node be embedded for each object? To use, set to "true"
  + embed_sensor (string, optional)
      Should the related sensor be embedded for each object? To use, set to "true"
  + of_project (string, optional)
      Filters the results to only those who have a relationship to the given project. To use, set value as a Project Slug.
  + of_projects (string, optional)
      Filters the results to only those who have a relationship to the given project. To use, set value as a Project Slug.
  + from_node (string, optional)
      Filters the results to only those who have a relationship to the given node. To use, set value as a Node VSN.
  + from_nodes (string, optional)
      Filters the results to only those who have a relationship to the given node. To use, set value as a Node VSN.
  + by_sensor (string, optional)
      Filters the results to only those who have a relationship to the given sensor. To use, set value as a Sensor Path.
  + by_sensors (string, optional)
      Filters the results to only those who have a relationship to the given sensor. To use, set value as a Sensor Path.
  + location (object, optional)
      Filters the results to only those whose location is within or within distance from the filter geometry value.
  + timestamp (string, optional)
      Filters the results to only those whose `timestamp` attribute satisfies the query.
  + hrf (string, optional)
      Filters the results to only those whose `hrf` value attribute satisfies the query.
  + raw (string, optional)
      Filters the results to only those whose `raw` value attribute satisfies the query.
  + aggregates (string, optional)
      Computes aggregates for the HRF and raw value fields.
  + as_histogram (string, optional)
      Computes a histogram for the observations.
  + as_time_buckets (string, optional)
      Computes aggregates for the observations partitioned by equally sized time frames.

+ Response 200 (application/json)

{
  "data": [
    {
      "timestamp": "2018-10-19T19:05:45",
      "sensor_path": "chemsense.co.concentration",
      "raw": 3235.0,
      "node_vsn": "088",
      "hrf": null
    },
    {
      "timestamp": "2018-10-19T19:05:45",
      "sensor_path": "chemsense.o3.concentration",
      "raw": 2007.0,
      "node_vsn": "088",
      "hrf": null
    },
    {
      "timestamp": "2018-10-19T19:05:45",
      "sensor_path": "chemsense.oxidizing_gases.concentration",
      "raw": 6128.0,
      "node_vsn": "088",
      "hrf": null
    },
    {
      "timestamp": "2018-10-19T19:05:45",
      "sensor_path": "chemsense.reducing_gases.concentration",
      "raw": 5175.0,
      "node_vsn": "088",
      "hrf": null
    },
    {
      "timestamp": "2018-10-19T19:05:45",
      "sensor_path": "chemsense.si1145.ir_intensity",
      "raw": 1522.0,
      "node_vsn": "088",
      "hrf": null
    }
  ]
}

### Simple Aggregate Values [GET]

+ Parameters
  + by_sensor (string, optional)
      Default: "wagman.htu21d.temperature"
  + aggregates (string, optional)
      Format the value as `{{ aggregate func }}:{{ grouping field }}`
      Default: "avg:sensor_path"

+ Response 200 (application/json)

{
  "data": [
    {
      "raw_avg": 3272.0,
      "hrf_avg": null,
      "group": "chemsense.co.concentration"
    },
    {
      "raw_avg": 3226.0,
      "hrf_avg": null,
      "group": "chemsense.h2s.concentration"
    },
    {
      "raw_avg": 812.0,
      "hrf_avg": null,
      "group": "chemsense.no2.concentration"
    },
    {
      "raw_avg": 3661.0,
      "hrf_avg": null,
      "group": "chemsense.o3.concentration"
    }
  ]
}

### Aggregate with a Histogram [GET]

+ Parameters
  + by_sensor (string, optional)
      Default: "wagman.htu21d.temperature"
  + as_histogram (string, optional)
      Format the value as `{{ raw min }}:{{ raw max }}:{{ hrf min }}:{{ hrf max }}:{{ grouping field }}`
      Default: "0:100:0:100:3:node_vsn"

+ Response 200 (application/json)

{
  "data": [
    {
      "raw_histogram": [ 0, 1, 0, 0, 0 ],
      "hrf_histogram": [ 0, 1, 0, 0, 0 ],
      "group": "006"
    },
    {
      "raw_histogram": [ 0, 1, 0, 0, 0 ],
      "hrf_histogram": [ 0, 1, 0, 0, 0 ],
      "group": "00D"
    }
  ]
}

### Aggregate as Time Buckets [GET]

+ Parameters
  + by_sensor (string, optional)
      Default: "wagman.htu21d.temperature"
  + as_time_buckets (string, optional)
      Format the value as `{{ aggregate func }}:{{ interval }}`
      Default: "avg:1 hour"

+ Response 200 (application/json)

{
  "data": [
    {
      "raw_avg": 27.47222222222222,
      "hrf_avg": 27.47222222222222,
      "bucket": "2018-10-18T22:00:00.000000"
    },
    {
      "raw_avg": 26.524390243902438,
      "hrf_avg": 26.524390243902438,
      "bucket": "2018-10-18T23:00:00.000000"
    },
    {
      "raw_avg": 25.134146341463413,
      "hrf_avg": 25.134146341463413,
      "bucket": "2018-10-19T00:00:00.000000"
    },
    {
      "raw_avg": 24.0125,
      "hrf_avg": 24.0125,
      "bucket": "2018-10-19T01:00:00.000000"
    },
    {
      "raw_avg": 23.03614457831325,
      "hrf_avg": 23.03614457831325,
      "bucket": "2018-10-19T02:00:00.000000"
    },
    {
      "raw_avg": 22.185185185185187,
      "hrf_avg": 22.185185185185187,
      "bucket": "2018-10-19T03:00:00.000000"
    },
    {
      "raw_avg": 21.428571428571427,
      "hrf_avg": 21.428571428571427,
      "bucket": "2018-10-19T04:00:00.000000"
    },
    {
      "raw_avg": 21.571428571428573,
      "hrf_avg": 21.571428571428573,
      "bucket": "2018-10-19T05:00:00.000000"
    },
    {
      "raw_avg": 19.0,
      "hrf_avg": 19.0,
      "bucket": "2018-10-19T09:00:00.000000"
    },
    {
      "raw_avg": 19.75,
      "hrf_avg": 19.75,
      "bucket": "2018-10-19T10:00:00.000000"
    },
    {
      "raw_avg": 20.654545454545456,
      "hrf_avg": 20.654545454545456,
      "bucket": "2018-10-19T11:00:00.000000"
    },
    {
      "raw_avg": 20.666666666666668,
      "hrf_avg": 20.666666666666668,
      "bucket": "2018-10-19T12:00:00.000000"
    },
    {
      "raw_avg": 20.924242424242426,
      "hrf_avg": 20.924242424242426,
      "bucket": "2018-10-19T13:00:00.000000"
    },
    {
      "raw_avg": 21.05128205128205,
      "hrf_avg": 21.05128205128205,
      "bucket": "2018-10-19T14:00:00.000000"
    },
    {
      "raw_avg": 22.20731707317073,
      "hrf_avg": 22.20731707317073,
      "bucket": "2018-10-19T15:00:00.000000"
    },
    {
      "raw_avg": 22.646341463414632,
      "hrf_avg": 22.646341463414632,
      "bucket": "2018-10-19T16:00:00.000000"
    },
    {
      "raw_avg": 22.2375,
      "hrf_avg": 22.2375,
      "bucket": "2018-10-19T17:00:00.000000"
    },
    {
      "raw_avg": 21.566265060240966,
      "hrf_avg": 21.566265060240966,
      "bucket": "2018-10-19T18:00:00.000000"
    },
    {
      "raw_avg": 21.571428571428573,
      "hrf_avg": 21.571428571428573,
      "bucket": "2018-10-19T19:00:00.000000"
    }
  ]
}