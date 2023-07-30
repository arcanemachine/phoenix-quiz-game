defmodule QuizGameWeb.BaseRouter do
  @moduledoc """
  The base router. Used for routes that do not belong to a particular context.
  """

  def browser do
    quote do
      scope "/", QuizGameWeb do
        pipe_through(:browser)

        get("/", BaseController, :home)
        get("/privacy-policy", BaseController, :privacy_policy)
        get("/terms-of-use", BaseController, :terms_of_use)
      end
    end
  end

  @doc """
  When used, dispatch the appropriate function by calling the desired function name as an atom.

  ## Examples

      use BaseRouter, :base_browser
      use BaseRouter, :base_api
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
