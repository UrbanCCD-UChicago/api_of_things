defmodule AotWeb.RawObservationController do
  use AotWeb, :controller

  alias Aot.Data
  # alias Aot.Data.RawObservation

  # action_fallback AotWeb.FallbackController

  def index(conn, _params) do
    raw_observations = Data.list_raw_observations()
    render(conn, "index.json", raw_observations: raw_observations)
  end

  def show(conn, %{"id" => id}) do
    raw_observation = Data.get_raw_observation!(id)
    render(conn, "show.json", raw_observation: raw_observation)
  end

  # def create(conn, %{"raw_observation" => raw_observation_params}) do
  #   with {:ok, %RawObservation{} = raw_observation} <- Data.create_raw_observation(raw_observation_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", raw_observation_path(conn, :show, raw_observation))
  #     |> render("show.json", raw_observation: raw_observation)
  #   end
  # end

  # def update(conn, %{"id" => id, "raw_observation" => raw_observation_params}) do
  #   raw_observation = Data.get_raw_observation!(id)
  #
  #   with {:ok, %RawObservation{} = raw_observation} <- Data.update_raw_observation(raw_observation, raw_observation_params) do
  #     render(conn, "show.json", raw_observation: raw_observation)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   raw_observation = Data.get_raw_observation!(id)
  #   with {:ok, %RawObservation{}} <- Data.delete_raw_observation(raw_observation) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
