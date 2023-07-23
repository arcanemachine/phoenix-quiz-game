defmodule QuizGameWeb.Router.Base do
  @moduledoc """
  The base router.
  """

  def base_browser do
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

      use BaseRouter, :base_allow_any_user
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
