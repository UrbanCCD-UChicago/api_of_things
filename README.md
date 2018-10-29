# Array of Things HTTP API

The Array of Things is an experimental urban sensing project. More information
about the project can be found at [arrayofthings.org](https://arrayofthings.org/).

This application is live at [https://api.arrayofthings.org/](https://api.arrayofthings.org/).

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

## Development and Contributing

The API is built using Elixir, PostgreSQL, and the PostGIS and TimescaleDB extensions.

The easiest way to install Elixir is using the [ASDF VM](https://github.com/asdf-vm/asdf)
and installing the _erlang_ and _elixir_ plugins. Once you have those, you can simply
cd into this project directory and `asdf install`.

Building Postgres with the requisite extensions is a pain. The easy route to all of this
is to use docker and pull in the `timescale/timescaledb-postgis` image. The image is 
PostgreSQL 10 with PostGIS and TimescaleDB already installed.

We welcome all bug reports, pull requests and companion client libraries.