defmodule QuizGameWeb.BaseRouter do
  @moduledoc """
  Routes that do not belong to a particular context.
  """

  def browser do
    quote do
      scope "/", QuizGameWeb do
        pipe_through(:browser)

        get("/", BaseController, :home)
        live("/contact-us", BaseLive.ContactUsLive, :contact_us)
        get("/privacy-policy", BaseController, :privacy_policy)
        get("/terms-of-use", BaseController, :terms_of_use)
      end
    end
  end

  @doc """
  When used, dispatch the appropriate function by calling the desired function name as an atom.

  ## Examples

      use BaseRouter, :api
      use BaseRouter, :browser
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
