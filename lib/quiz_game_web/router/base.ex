defmodule QuizGameWeb.Router.Base do
  @moduledoc """
  The base router. Used for routes that do not belong to a particular context.
  """

  def routes do
    %{
      root: "/",
      privacy_policy: "/privacy-policy",
      terms_of_use: "/terms-of-use"
    }
  end

  def browser do
    quote do
      scope @routes.base.root, QuizGameWeb do
        pipe_through(:browser)

        get(@routes.base.root, BaseController, :home)
        get(@routes.base.privacy_policy, BaseController, :privacy_policy)
        get(@routes.base.terms_of_use, BaseController, :terms_of_use)
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
