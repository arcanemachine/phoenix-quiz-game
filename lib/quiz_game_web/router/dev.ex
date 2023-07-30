defmodule QuizGameWeb.Router.Dev do
  @moduledoc """
  A router for routes that are only available in development.
  """

  defmacro __using__(_opts) do
    quote do
      if Application.compile_env(:quiz_game, :dev_routes) do
        import Phoenix.LiveDashboard.Router

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
