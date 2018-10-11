defmodule AotWeb.Testing.ObservationControllerTest do
  use Aot.Testing.BaseCase
  use Aot.Testing.DataCase
  use AotWeb.Testing.ConnCase

  describe "index" do
    test "response data should be an array of objects", %{conn: conn} do
      %{"data" => data} =
        conn
        |> get(observation_path(conn, :index))
        |> json_response(:ok)

      assert is_list(data)

      data
      |> Enum.each(& assert is_map(&1))
    end
  end
end
