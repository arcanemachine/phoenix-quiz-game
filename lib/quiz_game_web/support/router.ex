defmodule QuizGameWeb.Support.Router do
  @moduledoc "This project's router helpers."
  use QuizGameWeb, :verified_routes

  @typedoc "The contexts available for route matching."
  @type context :: :base | :quizzes | :users

  @doc """
  Match against a route with no URL parameters.

  ## Examples

      iex> path(:users, :login)
      "/users/login"
  """

  @spec route(context, atom()) :: String.t()
  def route(context, action), do: route(context, action, [])

  @doc """
  Match against a route that contains URL parameters.

  ## Examples

      iex> path(:users, :confirmation, token: 123)
      "/users/confirm/email/123"
  """

  @spec route(context, atom(), keyword()) :: String.t()
  def route(context, action, opts)

  def route(:base, action, _opts) do
    case action do
      :root -> ~p"/"
      :contact_us -> ~p"/contact-us"
      :privacy_policy -> ~p"/privacy-policy"
      :terms_of_use -> ~p"/terms-of-use"
    end
  end

  def route(:quizzes, action, opts) do
    case action do
      :index -> ~p"/quizzes"
      :new -> ~p"/quizzes/new"
      :create -> ~p"/quizzes"
      :edit -> ~p"/quizzes/#{opts[:quiz_id]}/edit"
      n when n in [:show, :update, :delete] -> ~p"/quizzes/#{opts[:quiz_id]}"
    end
  end

  # credo:disable-for-next-line
  def route(:users, action, opts) do
    case action do
      # auth
      :registration -> ~p"/users/register"
      :confirmation_instructions -> ~p"/users/confirm/email"
      :confirmation -> ~p"/users/confirm/email/#{opts[:token]}"
      :login -> ~p"/users/login"
      :logout_confirm -> ~p"/users/logout"
      :logout -> ~p"/users/logout"
      :forgot_password -> ~p"/users/reset-password"
      :reset_password -> ~p"/users/reset-password/#{opts[:token]}"
      # crud
      :show -> ~p"/users/me"
      :settings -> ~p"/users/me/update"
      :update_email -> ~p"/users/me/update/email"
      :update_email_confirm -> ~p"/users/me/update/email/confirm/#{opts[:token]}"
      :update_password -> ~p"/users/me/update/password"
      :delete_confirm -> ~p"/users/me/delete"
      :delete -> ~p"/users/me/delete"
    end
  end
end
