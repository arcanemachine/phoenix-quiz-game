defmodule QuizGameWeb.DevRouter do
  @moduledoc """
  Routes that are only available in development.
  """

  @doc """
  Embeds dev routes into the router.

  ## Examples

      use DevRouter
  """
  defmacro __using__(_opts) do
    quote do
      if Application.compile_env(:quiz_game, :dev_routes) do
        import Phoenix.LiveDashboard.Router

        alias QuizGameWeb.DevLive

        scope "/dev" do
          pipe_through(:browser)

          # built-in
          live_dashboard("/dashboard", metrics: QuizGameWeb.Telemetry)
          forward "/mailbox", Plug.Swoosh.MailboxPreview

          # custom
          live("/component-showcase", DevLive.ComponentShowcaseLive)
        end
      end
    end
  end
end
