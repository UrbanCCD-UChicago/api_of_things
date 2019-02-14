defmodule AotWeb.ControllerUtils do
  import Plug.Conn, only: [put_resp_header: 3, resp: 3, halt: 1]
  import Plug.Conn.Status, only: [code: 1, reason_phrase: 1]
  alias Plug.Conn

  def halt_with(conn, status) do
    status_code = code(status)
    message = reason_phrase(status_code)

    do_halt_with(conn, status_code, message)
  end

  def halt_with(conn, status, message) do
    status_code = code(status)
    do_halt_with(conn, status_code, message)
  end

  defp do_halt_with(conn, code, message) do
    body = %{error: message} |> Jason.encode!()

    conn
    |> put_resp_header("content-type", "application/json")
    |> resp(code, body)
    |> halt()
  end

  def build_meta(url_func, controller_func, conn) do
    %{
      links: %{
        previous: prev_link(url_func, controller_func, conn),
        current: url_func.(conn, controller_func, conn.params),
        next: next_link(url_func, controller_func, conn)
      }
    }
  end

  defp prev_link(url_func, controller_func, %Conn{params: params} = conn) do
    case Map.get(params, "page") do
      nil -> nil
      1 -> nil
      page ->
        page =
          if is_binary(page) do
            {page, _} = Integer.parse(page)
            page
          else
            page
          end
        url_func.(conn, controller_func, Map.put(params, "page", page - 1))
    end
  end

  defp next_link(url_func, controller_func, %Conn{params: params} = conn) do
    case Map.get(params, "page") do
      nil -> nil
      page ->
        page =
          if is_binary(page) do
            {page, _} = Integer.parse(page)
            page
          else
            page
          end
        url_func.(conn, controller_func, Map.put(params, "page", page + 1))
    end
  end
end
