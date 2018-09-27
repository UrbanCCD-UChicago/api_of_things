defmodule AotWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: AotWeb
      import Plug.Conn
      import AotWeb.Router.Helpers
      import AotWeb.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/aot_web/templates", namespace: AotWeb
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]
      import AotWeb.Router.Helpers
      import AotWeb.ErrorHelpers
      import AotWeb.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import AotWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
