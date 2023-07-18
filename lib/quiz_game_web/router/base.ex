defmodule QuizGameWeb.Router.Base do
  @moduledoc false

  # BROWSER #
  def base_allow_any_user do
    quote do
      get("/", BaseController, :home)
      get("/privacy-policy", BaseController, :privacy_policy)
      get("/terms-of-use", BaseController, :terms_of_use)
    end
  end

  # DEV #
  def base_dev do
    quote do
      if Application.compile_env(:quiz_game, :dev_routes) do
        import Phoenix.LiveDashboard.Router

        alias QuizGameWeb.Base.ComponentShowcaseLive

        scope "/dev" do
          pipe_through(:browser)

          live("/component-showcase", ComponentShowcaseLive)

          live_dashboard("/dashboard", metrics: TodoListWeb.Telemetry)
          forward "/mailbox", Plug.Swoosh.MailboxPreview
        end
      end
    end
  end

  @doc """
  When used, dispatch the appropriate function by calling the desired function name as an atom.

  ## Examples

      use BaseRouter, :base_allow_any_user
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
