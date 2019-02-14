defmodule AotWeb.NodePlugs do
  @moduledoc ""

  import Plug.Conn, only: [assign: 3]
  alias Plug.Conn

  def with_sensors(%Conn{params: %{"with_sensors" => _}} = conn, _), do: assign(conn, :with_sensors, true)
  def with_sensors(conn, _), do: conn
end
