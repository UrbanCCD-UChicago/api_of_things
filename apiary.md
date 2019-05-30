FORMAT: 1A
HOST: https://api.arrayofthings.org/api

# Array of Things HTTP API

Welcome the Array of Things HTTP API!

The Array of Things (AoT) is an experimental environmental sensing project. More information about the project can be found at [https://arrayofthings.org/](https://arrayofthings.org/).


# Data, Entities and Relationships

**Data, in the sense of sensor measurements and node metrics, are maintained in the API for one week.** After a week, the data is expunged from the database. If you need data that is older than seven days, we recommend you use the [AoT File Browser](https://afb.plenar.io/) to access the full data sets.

**Results from the API are returned as _pages_ of data**, and can be sized and iterated against using the `order`, `page` and `size` query parameters. 

The `size` parameter controls the number of results returned in the page. It must be an integer between `1` and `5000`. The default value is `200`.

The `page` parameter controls which page of data is being returned. It must be an integer of at least `1` with no enforced maximum -- values that exceed the number of records available for a given entity will return an empty page. The default value is `1`.

The `order` parameter controls the ordering of the results in the page. It is a string, and it must follow the format `{direction}:{field}` where direction is one of `asc` for ascending order or `desc` for descending order, and `field` is the field name of the entity to order on. Each entity has its own default ordering:

- projects are arranged by `slug` in ascending order
- nodes are arranged by `vsn` in ascending order
- sensors are arranged by `path` in ascending order
- observations and metrics are arranged by `timestamp` in descending order

The following listings describe the entities made available via the API.

## Projects

The Array of Things is geographically distributed globally. Nodes within the system are arranged by projects. Most commonly these projects are named for major urban centers or universities that administer the nodes. For example, our largest deployment of nodes is in the city of Chicago so we have a project named `chicago` to track those nodes; just as we have a set of nodes administered by Vanderbilt University and project named `vanderbilt`.

| Field         | Type                                      | Description                                                                               |
| ------------- | ----------------------------------------- | ----------------------------------------------------------------------------------------- |
| name          | string                                    | The full name of the project                                                              |
| slug          | string                                    | The [slugged name](https://en.wikipedia.org/wiki/Clean_URL#Slug) used to build references |
| hull          | [geojson object](https://geojson.org/)    | The convex hull of the nodes that are part of the project                                 |
| archive_url   | string                                    | The link to the full CSV archive of the project's data                                    |

## Nodes

Nodes are the physical devices that are deployed to record measurements. They are typically comprised of several sensors that record multiple observation types.

| Field         | Type                                      | Description                                   |
| ------------- | ----------------------------------------- | --------------------------------------------- |
| vsn           | string                                    | The unique identifier of the node -- its name |
| location      | [geojson object](https://geojson.org/)    | The coordinates of the node                   |
| address       | string                                    | The human readable location of the node       |
| description   | string                                    | Additional information about the node         |

## Sensors

Sensors are the (usually, although not always) physical devices onboard the nodes that record measurements. In some instances, sensors are purely software based and rely on one or more other physical devices for input to record their observations -- for example the image detection sensors use a single camera input to determine car and pedestrian counts at intersections.

| Field         | Type      | Description                                                       |
| ------------- | --------- | ----------------------------------------------------------------- |
| path          | string    | The unique identifier of the sensor -- its name                   |
| uom           | string    | The unit of measurement the sensor records its observations in    |
| min           | float     | The typical minimum value of the observation values recorded      |
| max           | float     | The typical maximum value of the observation values recorded      |
| data_sheet    | string    | A link to the sensor's data sheet                                 |

## Observations and Metrics

Sensors record their measurements, and those are collected as one of two different types: _observations_ are the environmental measurements that are recorded (e.g. temperature), and _metrics_ are the system measurements collected for monitoring and error reporting (e.g. CPU load). They both have the same table structure and are separated only because they are interesting to different groups of users -- someone designing a map of urban heat islands probably doesn't care much about the humidity inside of the node, just as I (an AoT admin) want to be able to create applications to monitor node state and send alerts when things go sideways.

| Field         | Type                                      | Description                                                       |
| ------------- | ----------------------------------------- | ----------------------------------------------------------------- |
| node_van      | string                                    | The reference to the node from which the measurement was recorded |
| sensor_path   | string                                    | The reference to the sensor that recorded the measurement         |
| location      | [geojson object](https://geojson.org/)    | The coordinates of the node when the measurement was recorded     |
| timestamp     | UTC date time string                      | The date and time (in UTC) that the measurement was recorded      |
| value         | float                                     | The value of the recorded measurement                             |
| uom           | string                                    | The unit of measurement of the recorded measurement               |


# The API Endpoints

Each entity type has its own endpoint in the API.

**NOTE:** The API has a rate limit of 1,000 requests per minute per IP address.

## Project [/projects/{slug}]

Get a single project.

+ Parameters
    + slug (string) - The slug value of the project you want detailed information from.

### Project Details [GET]

+ Parameters
    + slug (string) - The slug value of the project you want detailed information from.
        + Default chicago

+ Response 200 (application/json)

    {"data":{"slug":"chicago","name":"Chicago","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.latest.tar"}}


## Projects [/projects{?order,size,page,format}]

Page through projects.

+ Parameters
    + order (string, optional) - Controls the ordering of the results in the page. It must follow the format `{direction}:{field}` where direction is one of `asc` for ascending order or `desc` for descending order, and `field` is the field name of the entity to order on. The default is `asc:name`.
    + size (number, optional) - Controls the number of results returned in the page. It must be an integer between `1` and `5000`. The default value is `200`.
    + page (number, optional) - Controls which page of data is being returned. It must be an integer of at least `1` with no enforced maximum -- values that exceed the number of records available for a given entity will return an empty page. The default value is `1`.
    + format (string, optional) - Controls the type of the data returned. It must be one of `json` or `geojson`. The default value is `json`.

### List Projects [GET]

+ Response 200 (application/json)

    {"meta":{"links":{"previous":null,"next":"https://api-of-things.plenar.io/api/projects?order=asc%3Aname&page=2&size=200","current":"https://api-of-things.plenar.io/api/projects?order=asc%3Aname&page=1&size=200"}},"data":[{"slug":"bristol","name":"Bristol","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Bristol.complete.latest.tar"},{"slug":"chicago","name":"Chicago","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Chicago.complete.latest.tar"},{"slug":"denver","name":"Denver","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Denver.complete.latest.tar"},{"slug":"detroit","name":"Detroit","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Detroit.complete.latest.tar"},{"slug":"ga-tech","name":"GA Tech","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_GA_Tech.complete.latest.tar"},{"slug":"gasp","name":"GASP","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/GASP.complete.latest.tar"},{"slug":"linknyc","name":"LinkNYC","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/LinkNYC.complete.latest.tar"},{"slug":"niu","name":"NIU","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_NIU.complete.latest.tar"},{"slug":"nucwr-mugs","name":"NUCWR-MUGS","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/NUCWR-MUGS.complete.latest.tar"},{"slug":"portland","name":"Portland","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Portland.complete.latest.tar"},{"slug":"rune-test","name":"Rune Test","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/Rune_Test.complete.latest.tar"},{"slug":"seattle","name":"Seattle","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Seattle.complete.latest.tar"},{"slug":"stanford","name":"Stanford","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Stanford.complete.latest.tar"},{"slug":"syracuse","name":"Syracuse","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Syracuse.complete.latest.tar"},{"slug":"unc","name":"UNC","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_UNC.complete.latest.tar"},{"slug":"uw","name":"UW","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_UW.complete.latest.tar"},{"slug":"vanderbilt","name":"Vanderbilt","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Vanderbilt.complete.latest.tar"},{"slug":"waggle-dronebears","name":"Waggle Dronebears","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/Waggle_Dronebears.complete.latest.tar"},{"slug":"waggle-others","name":"Waggle Others","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/Waggle_Others.complete.latest.tar"},{"slug":"waggle-tokyo","name":"Waggle Tokyo","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/Waggle_Tokyo.complete.latest.tar"}]}

### List Projects in a 2 Sized Page, Second Page [GET]

+ Parameters
    + size (number, optional) - Controls the number of results returned in the page. It must be an integer between `1` and `5000`. The default value is `200`.
        + Default: 2
    + page (number, optional) - Controls which page of data is being returned. It must be an integer of at least `1` with no enforced maximum -- values that exceed the number of records available for a given entity will return an empty page. The default value is `1`.
        + Default: 2

+ Response 200 (application/json)

    {"meta":{"links":{"previous":"https://api-of-things.plenar.io/api/projects?order=asc%3Aname&page=1&size=2","next":"https://api-of-things.plenar.io/api/projects?order=asc%3Aname&page=3&size=2","current":"https://api-of-things.plenar.io/api/projects?order=asc%3Aname&page=2&size=2"}},"data":[{"slug":"denver","name":"Denver","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Denver.complete.latest.tar"},{"slug":"detroit","name":"Detroit","hull":null,"archive_url":"https://www.mcs.anl.gov/research/projects/waggle/downloads/datasets/AoT_Detroit.complete.latest.tar"}]}


## Node [/nodes/{vsn}]

Get a single node.

+ Parameters
    + vsn (string) - The vsn value of the node you want detailed information from.

### Node Details [GET]

+ Parameters
    + vsn (string) - The vsn value of the node you want detailed information from.
        + Default: 004

+ Response 200 (application/json)

    {"data":{"vsn":"004","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-87.627678,41.878377]}},"description":"AoT Chicago (S) [C]","address":"State St & Jackson Blvd Chicago IL"}}


## Nodes [/nodes{?order,size,page,format,location,project}]

Page through nodes.

There is a special parameter for this endpoint: `location`. The parameter takes a special format to filter results. 

`?location=within:{GeoJSON object}` filters results to those whose location value is _within_ the given GeoJSON object. This is to say that a node resides within a given bounding box.

`?location=diwithin:{distance in meters}:{GeoJSON object}` filters results to those whose location is _within the given distance from_ the given GeoJSON object. This is to say that a node is location within X meters from a given point.

The format of the GeoJSON object is a fully URL encoded object. In its full format (without encoding), you would specify values such as:

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

or 

```
?location=dwithin:2000:{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [1,2],
    "crs": {
      "type": "name",
      "properties": {
        "name": "EPSG:4326"
      }
    }
  }
}
```

+ Parameters
    + order (string, optional) - Controls the ordering of the results in the page. It must follow the format `{direction}:{field}` where direction is one of `asc` for ascending order or `desc` for descending order, and `field` is the field name of the entity to order on. The default is `asc:vsn`.
    + size (number, optional) - Controls the number of results returned in the page. It must be an integer between `1` and `5000`. The default value is `200`.
    + page (number, optional) - Controls which page of data is being returned. It must be an integer of at least `1` with no enforced maximum -- values that exceed the number of records available for a given entity will return an empty page. The default value is `1`.
    + format (string, optional) - Controls the type of the data returned. It must be one of `json` or `geojson`. The default value is `json`.
    + location (object,optional) - See notes above. The default is `null`.
    + project (string, optional) - Filters the results to those who are related to the project slug. Default is `null`.

### List Nodes [GET]

+ Parameters
    + size (number, optional) - Controls the number of results returned in the page. It must be an integer between `1` and `5000`. The default value is `200`.
        + Default: 5

+ Response 200 (application/json)

    {"meta":{"links":{"previous":null,"next":"https://api-of-things.plenar.io/api/nodes?order=asc%3Avsn&page=2&size=5","current":"https://api-of-things.plenar.io/api/nodes?order=asc%3Avsn&page=1&size=5"}},"data":[{"vsn":"003","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[0.0,0.0]}},"description":"AoT Chicago (T) - Replace","address":"TCS 4302 - Returned from CDOT 04 Dec 2017"},{"vsn":"004","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-87.627678,41.878377]}},"description":"AoT Chicago (S) [C]","address":"State St & Jackson Blvd Chicago IL"},{"vsn":"005","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[0.0,0.0]}},"description":"AoT UNC (S) [C]","address":"TBD"},{"vsn":"006","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-87.616055,41.858136]}},"description":"AoT Chicago (S)","address":"18th St & Lake Shore Dr Chicago IL"},{"vsn":"007","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[0.0,0.0]}},"description":"AoT Node (S)","address":"TCS 4302 P2,S7"}]}

### List Nodes, Limit to Chicago, Return GeoJSON [GET]

+ Parameters
    + size (number, optional) - Controls the number of results returned in the page. It must be an integer between `1` and `5000`. The default value is `200`.
        + Default: 5
    + format (string, optional) - Controls the type of the data returned. It must be one of `json` or `geojson`. The default value is `json`.
        + Default: geojson
    + project (string, optional) - Filters the results to those who are related to the project slug. Default is `null`.
        + Default: chicago

+ Response 200 (application/json)

    {"meta":{"links":{"previous":null,"next":"https://api-of-things.plenar.io/api/nodes?format=geojson&order=asc%3Avsn&page=2&project=chicago&size=5","current":"https://api-of-things.plenar.io/api/nodes?format=geojson&order=asc%3Avsn&page=1&project=chicago&size=5"}},"data":[{"type":"Feature","properties":{"vsn":"004","description":"AoT Chicago (S) [C]","address":"State St & Jackson Blvd Chicago IL"},"geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-87.627678,41.878377]}},{"type":"Feature","properties":{"vsn":"006","description":"AoT Chicago (S)","address":"18th St & Lake Shore Dr Chicago IL"},"geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-87.616055,41.858136]}},{"type":"Feature","properties":{"vsn":"00A","description":"AoT Chicago (S) [CA]","address":"Lake Shore Drive & Fullerton Ave Chicago IL"},"geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-87.6307578,41.9262614]}},{"type":"Feature","properties":{"vsn":"00D","description":"AoT Chicago (S)","address":"Cornell & 47th St Chicago IL"},"geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-87.590228,41.810342]}},{"type":"Feature","properties":{"vsn":"010","description":"AoT Chicago (S) [C]","address":"Homan Ave & Roosevelt Rd Chicago IL"},"geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-87.710543,41.866349]}}]}


## Sensor [/sensors/{path}]

Get a single sensor.

+ Parameters
    + path (string) - The path value of the sensor you want detailed information from.

### Sensor Details [GET]

+ Parameters
    + path (string) - The path value of the sensor you want detailed information from.
        + Default metsense.htu21d.temperature

+ Response 200 (application/json)

    {"data":{"uom":"C","path":"metsense.htu21d.temperature","min":-40.0,"max":125.0,"data_sheet":"https://github.com/waggle-sensor/sensors/raw/master/sensors/datasheets/htu21d.pdf"}}


## Sensors [/sensors{?order,size,page}]

Page through sensors.

+ Parameters
    + order (string, optional) - Controls the ordering of the results in the page. It must follow the format `{direction}:{field}` where direction is one of `asc` for ascending order or `desc` for descending order, and `field` is the field name of the entity to order on. The default is `asc:path`.
    + size (number, optional) - Controls the number of results returned in the page. It must be an integer between `1` and `5000`. The default value is `200`.
    + page (number, optional) - Controls which page of data is being returned. It must be an integer of at least `1` with no enforced maximum -- values that exceed the number of records available for a given entity will return an empty page. The default value is `1`.

### List Sensors [GET]

+ Response 200 (application/json)

    {"meta":{"links":{"previous":null,"next":"https://api-of-things.plenar.io/api/sensors?order=asc%3Apath&page=2&size=5","current":"https://api-of-things.plenar.io/api/sensors?order=asc%3Apath&page=1&size=5"}},"data":[{"uom":"counts","path":"alphasense.opc_n2.bins","min":0.0,"max":null,"data_sheet":"https://github.com/waggle-sensor/sensors/raw/master/sensors/datasheets/opcn2.pdf"},{"uom":null,"path":"alphasense.opc_n2.fw","min":null,"max":null,"data_sheet":"https://github.com/waggle-sensor/sensors/raw/master/sensors/datasheets/opcn2.pdf"},{"uom":"μg/m^3","path":"alphasense.opc_n2.pm1","min":0.0,"max":null,"data_sheet":"https://github.com/waggle-sensor/sensors/raw/master/sensors/datasheets/opcn2.pdf"},{"uom":"μg/m^3","path":"alphasense.opc_n2.pm10","min":0.0,"max":null,"data_sheet":"https://github.com/waggle-sensor/sensors/raw/master/sensors/datasheets/opcn2.pdf"},{"uom":"μg/m^3","path":"alphasense.opc_n2.pm2_5","min":0.0,"max":null,"data_sheet":"https://github.com/waggle-sensor/sensors/raw/master/sensors/datasheets/opcn2.pdf"}]}


## Observations [/observations{?order,size,page,format,location,project,node,sensor,timestamp,value,histogram,time_bucket}]

Page through observations.

+ Parameters
    + order (string, optional) - Controls the ordering of the results in the page. It must follow the format `{direction}:{field}` where direction is one of `asc` for ascending order or `desc` for descending order, and `field` is the field name of the entity to order on. The default is `asc:vsn`.
    + size (number, optional) - Controls the number of results returned in the page. It must be an integer between `1` and `5000`. The default value is `200`.
    + page (number, optional) - Controls which page of data is being returned. It must be an integer of at least `1` with no enforced maximum -- values that exceed the number of records available for a given entity will return an empty page. The default value is `1`.
    + format (string, optional) - Controls the type of the data returned. It must be one of `json` or `geojson`. The default value is `json`.
    + location (object,optional) - See notes about the use of location in the nodes section above. The default is `null`.
    + project (string, optional) - Filters the results to those who are related to the project slug. Default is `null`.
    + node (string, optional) - Filters the results to those who are related to the node vsn. This can be an array value to limit to multiple nodes using the format `node[]=004&node[]=005`. Default is `null`.
    + sensor (string, optional) - Filters the results to those who are related to the sensor path. This can be an array value to limit to multiple sensors using the format `sensor[]=foo&sensor[]=bar`. Default is `null`.
    + timestamp (string, optional) - Filters the results to those whose values satisfy the given query. The format of the value must be `{function}:{comparator}` where _function_ is one of `eq`, `lt`, `le`, `gt` or `ge` and the _comparator_ is the value you are comparing against. Default is `null`.
    + value (string, optional) - Filters the results to those whose values satisfy the given query. The format of the value must be `{function}:{comparator}` where _function_ is one of `eq`, `lt`, `le`, `gt` or `ge` and the _comparator_ is the value you are comparing against. Default is `null`.
    + histogram (string, optional) - Returns a histogram of values. The format of the value must be `{min}::{max}::{number of buckets}`. This should be used in conjunction with at least a `sensor` param and usually in combination with `project`. Default is `null`.
    + time_bucket (string, optional) - Returns a histogram of values. The format of the value must be `{function}:{interval}` where _function_ is one of `min`, `max`, `avg` or `median` and _interval_ is PostgreSQL interval value (e.g. `6 hours`). This should be used in conjunction with at least a `sensor` param and usually in combination with `node` or `project`. Default is `null`.

### List Observations [GET]

+ Response 200 (application/json)

    {"meta":{"links":{"previous":null,"next":"https://api-of-things.plenar.io/api/observations?order=desc%3Atimestamp&page=2&size=5","current":"https://api-of-things.plenar.io/api/observations?order=desc%3Atimestamp&page=1&size=5"}},"data":[{"value":0.0,"uom":"μg/m^3","timestamp":"2019-05-21T17:14:02","sensor_path":"plantower.pms7003.point_5um_particle","node_vsn":"0C4","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-88.062771,41.922183]}}},{"value":1044.0,"uom":"μg/m^3","timestamp":"2019-05-21T17:14:02","sensor_path":"plantower.pms7003.point_3um_particle","node_vsn":"0C4","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-88.062771,41.922183]}}},{"value":8.0,"uom":"μg/m^3","timestamp":"2019-05-21T17:14:02","sensor_path":"plantower.pms7003.pm25_atm","node_vsn":"0C4","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-88.062771,41.922183]}}},{"value":5.0,"uom":"μg/m^3","timestamp":"2019-05-21T17:14:02","sensor_path":"plantower.pms7003.pm1_atm","node_vsn":"0C4","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-88.062771,41.922183]}}},{"value":8.0,"uom":"μg/m^3","timestamp":"2019-05-21T17:14:02","sensor_path":"plantower.pms7003.pm10_atm","node_vsn":"0C4","location":{"type":"Feature","geometry":{"type":"Point","crs":{"type":"name","properties":{"name":"EPSG:4326"}},"coordinates":[-88.062771,41.922183]}}}]}

### List Observations as a Histogram [GET]

+ Parameters
    + sensor (string, optional) - Filters the results to those who are related to the sensor path. This can be an array value to limit to multiple sensors using the format `sensor[]=foo&sensor[]=bar`. Default is `null`.
        + Default: metsense.htu21d.temperature
    + histogram (string, optional) - Returns a histogram of values. The format of the value must be `{min}::{max}::{number of buckets}`. This should be used in conjunction with at least a `sensor` param and usually in combination with `node` or `project`. Default is `null`.
        + Default: "0:100:10"

+ Response 200 (application/json)

    {"meta":{"links":{"previous":null,"next":null,"current":"https://api-of-things.plenar.io/api/observations?histogram=0%3A%3A100%3A%3A10&order=desc%3Atimestamp&sensor=metsense.htu21d.temperature"}},"data":[{"node_vsn":"004","histogram":[0,2312,17643,5075,0,0,0,0,0,0,0,0]},{"node_vsn":"007","histogram":[0,0,63,0,0,0,0,0,0,0,0,0]},{"node_vsn":"010","histogram":[0,620,7841,4391,0,0,0,0,0,0,0,0]},{"node_vsn":"01F","histogram":[0,1043,741,155,0,0,0,0,0,0,0,19335]},{"node_vsn":"020","histogram":[0,5200,10742,4524,0,0,0,0,0,0,0,0]},{"node_vsn":"02A","histogram":[0,5955,11681,4131,1,0,0,0,0,0,0,0]},{"node_vsn":"02D","histogram":[0,3255,13681,5468,0,0,0,0,0,0,0,0]},{"node_vsn":"04B","histogram":[0,0,0,3916,0,0,0,0,0,0,0,0]},{"node_vsn":"04C","histogram":[2543,17955,1295,64,0,0,0,0,0,0,0,0]},{"node_vsn":"051","histogram":[0,2776,11635,6991,173,0,0,0,0,0,0,0]},{"node_vsn":"056","histogram":[0,5175,10039,6515,0,0,0,0,0,0,0,0]},{"node_vsn":"062","histogram":[1003,6181,10710,3268,0,0,0,0,0,0,0,0]},{"node_vsn":"064","histogram":[0,0,20529,4386,0,0,0,0,0,0,0,0]},{"node_vsn":"065","histogram":[0,0,10999,3124,0,0,0,0,0,0,0,0]},{"node_vsn":"06B","histogram":[0,1754,4858,3027,0,0,0,0,0,0,0,0]},{"node_vsn":"071","histogram":[7637,13268,231,0,0,0,0,0,0,0,0,0]},{"node_vsn":"072","histogram":[0,1330,11417,3938,9,0,0,0,0,0,0,0]},{"node_vsn":"073","histogram":[12756,8878,19,76,0,0,0,0,0,0,0,0]},{"node_vsn":"077","histogram":[0,0,0,0,0,0,0,0,0,0,0,451]},{"node_vsn":"079","histogram":[0,0,0,0,0,0,0,0,0,0,0,21508]},{"node_vsn":"07A","histogram":[0,74,276,198,0,0,0,0,0,0,0,0]},{"node_vsn":"07C","histogram":[5,3788,11647,6011,0,0,0,0,0,0,0,0]},{"node_vsn":"07D","histogram":[0,0,972,0,0,0,0,0,0,0,0,21630]},{"node_vsn":"081","histogram":[0,0,0,0,0,0,0,0,0,0,0,21421]},{"node_vsn":"083","histogram":[0,0,0,0,0,0,0,0,0,0,0,24319]},{"node_vsn":"085","histogram":[0,2527,11548,6080,172,0,0,0,0,0,0,0]},{"node_vsn":"086","histogram":[0,0,0,0,0,0,0,0,0,0,0,21045]},{"node_vsn":"088","histogram":[6516,14059,329,90,0,0,0,0,0,0,0,0]},{"node_vsn":"089","histogram":[0,2667,12432,6431,0,0,0,0,0,0,0,0]},{"node_vsn":"08B","histogram":[0,3364,13540,4051,89,0,0,0,0,0,0,0]},{"node_vsn":"08C","histogram":[0,2402,7735,2536,0,0,0,0,0,0,0,8428]},{"node_vsn":"08F","histogram":[0,3419,14696,3298,0,0,0,0,0,0,0,0]},{"node_vsn":"092","histogram":[0,0,0,0,0,0,0,0,0,0,0,21310]},{"node_vsn":"09A","histogram":[0,4897,13144,7032,0,0,0,0,0,0,0,0]},{"node_vsn":"09C","histogram":[0,3492,14727,2933,0,0,0,0,0,0,0,0]},{"node_vsn":"0A3","histogram":[0,6044,9210,5553,0,0,0,0,0,0,0,0]},{"node_vsn":"0AA","histogram":[0,2803,8201,2460,0,0,0,0,0,0,0,8185]},{"node_vsn":"0AB","histogram":[0,0,0,74,0,0,0,0,0,0,0,0]},{"node_vsn":"0AD","histogram":[0,0,209,1703,0,0,0,0,0,0,0,0]},{"node_vsn":"0B1","histogram":[0,0,0,457,14,0,0,0,0,0,0,0]},{"node_vsn":"0B6","histogram":[0,1139,2080,446,0,0,0,0,0,0,0,0]},{"node_vsn":"0B8","histogram":[0,0,0,102,0,0,0,0,0,0,0,0]},{"node_vsn":"0BA","histogram":[0,661,970,186,0,0,0,0,0,0,0,0]},{"node_vsn":"0BC","histogram":[0,0,3721,0,0,0,0,0,0,0,0,0]},{"node_vsn":"0BE","histogram":[0,662,518,108,0,0,0,0,0,0,0,0]},{"node_vsn":"0C1","histogram":[0,0,1166,9517,7150,0,0,0,0,0,0,0]},{"node_vsn":"0C4","histogram":[0,0,0,6239,9,0,0,0,0,0,0,0]},{"node_vsn":"0C5","histogram":[0,0,829,7455,1397,0,0,0,0,0,0,0]},{"node_vsn":"0C6","histogram":[0,0,0,3709,13,0,0,0,0,0,0,0]},{"node_vsn":"0CE","histogram":[0,0,0,559,0,0,0,0,0,0,0,0]},{"node_vsn":"0E2","histogram":[0,0,0,136,168,0,0,0,0,0,0,0]},{"node_vsn":"0E5","histogram":[0,0,0,751,0,0,0,0,0,0,0,0]},{"node_vsn":"0E6","histogram":[0,0,0,3647,31,0,0,0,0,0,0,0]},{"node_vsn":"0E7","histogram":[0,0,0,0,25,0,0,0,0,0,0,0]},{"node_vsn":"0EA","histogram":[0,1090,8651,4171,0,0,0,0,0,0,0,0]},{"node_vsn":"0FD","histogram":[0,0,0,2577,34,0,0,0,0,0,0,0]},{"node_vsn":"100","histogram":[0,0,0,1095,0,0,0,0,0,0,0,0]},{"node_vsn":"11F","histogram":[0,0,0,2087,0,0,0,0,0,0,0,0]},{"node_vsn":"12D","histogram":[0,0,0,2366,394,0,0,0,0,0,0,0]},{"node_vsn":"131","histogram":[0,0,0,2557,559,0,0,0,0,0,0,0]},{"node_vsn":"145","histogram":[0,0,0,417,32,0,0,0,0,0,0,0]},{"node_vsn":"DLW04","histogram":[0,0,7478,4030,0,0,0,0,0,0,0,0]},{"node_vsn":"DLW11","histogram":[0,0,1215,705,0,0,0,0,0,0,0,0]},{"node_vsn":"NIUU01","histogram":[0,0,0,13596,0,0,0,0,0,0,0,0]},{"node_vsn":"W00D","histogram":[0,1,0,0,0,0,0,0,0,0,0,22683]}]}

### List Observations as Time Buckets [GET]

+ Parameters
    + node (string, optional) - Filters the results to those who are related to the node vsn. This can be an array value to limit to multiple nodes using the format `node[]=004&node[]=005`. Default is `null`.
        + Default: 004
    + sensor (string, optional) - Filters the results to those who are related to the sensor path. This can be an array value to limit to multiple sensors using the format `sensor[]=foo&sensor[]=bar`. Default is `null`.
        + Default: metsense.htu21d.temperature
    + time_bucket (string, optional) - Returns a histogram of values. The format of the value must be `{function}:{interval}` where _function_ is one of `min`, `max`, `avg` or `median` and _interval_ is PostgreSQL interval value (e.g. `6 hours`). This should be used in conjunction with at least a `sensor` param and usually in combination with `node` or `project`. Default is `null`.
        + Default: "median:6 hours"

+ Response 200 (application/json)

    {"meta":{"links":{"previous":null,"next":null,"current":"https://api-of-things.plenar.io/api/observations?node=004&order=desc%3Atimestamp&sensor=metsense.htu21d.temperature&time_bucket=median%3A6+hours"}},"data":[{"value":8.88,"bucket":"2019-05-13T00:00:00.000000"},{"value":10.62,"bucket":"2019-05-13T06:00:00.000000"},{"value":13.53,"bucket":"2019-05-13T12:00:00.000000"},{"value":15.34,"bucket":"2019-05-13T18:00:00.000000"},{"value":11.82,"bucket":"2019-05-14T00:00:00.000000"},{"value":14.39,"bucket":"2019-05-14T06:00:00.000000"},{"value":17.61,"bucket":"2019-05-14T12:00:00.000000"},{"value":18.17,"bucket":"2019-05-14T18:00:00.000000"},{"value":19.48,"bucket":"2019-05-15T00:00:00.000000"},{"value":19.575,"bucket":"2019-05-15T06:00:00.000000"},{"value":17.975,"bucket":"2019-05-15T12:00:00.000000"},{"value":21.17,"bucket":"2019-05-15T18:00:00.000000"},{"value":19.8,"bucket":"2019-05-16T00:00:00.000000"},{"value":11.81,"bucket":"2019-05-17T12:00:00.000000"},{"value":9.69,"bucket":"2019-05-17T18:00:00.000000"},{"value":10.535,"bucket":"2019-05-18T00:00:00.000000"},{"value":11.78,"bucket":"2019-05-18T06:00:00.000000"},{"value":16.9,"bucket":"2019-05-18T12:00:00.000000"},{"value":21.28,"bucket":"2019-05-18T18:00:00.000000"},{"value":18.48,"bucket":"2019-05-19T00:00:00.000000"},{"value":17.41,"bucket":"2019-05-19T06:00:00.000000"},{"value":22.205,"bucket":"2019-05-19T12:00:00.000000"},{"value":23.77,"bucket":"2019-05-19T18:00:00.000000"},{"value":19.25,"bucket":"2019-05-20T00:00:00.000000"},{"value":13.71,"bucket":"2019-05-20T06:00:00.000000"},{"value":12.44,"bucket":"2019-05-20T12:00:00.000000"},{"value":13.03,"bucket":"2019-05-20T18:00:00.000000"},{"value":12.37,"bucket":"2019-05-21T00:00:00.000000"},{"value":10.2,"bucket":"2019-05-21T06:00:00.000000"},{"value":10.65,"bucket":"2019-05-21T12:00:00.000000"}]}

