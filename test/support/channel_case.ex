defmodule AotWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ChannelTest
      @endpoint AotWeb.Endpoint
    end
  end
end
