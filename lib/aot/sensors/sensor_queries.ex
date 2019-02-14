defmodule Aot.Sensors.SensorQueries do
  @moduledoc ""

  defdelegate order(query, direction, field_name), to: Aot.QueryUtils
  defdelegate paginate(query, page_num, page_size), to: Aot.QueryUtils
end
