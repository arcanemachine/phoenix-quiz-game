defmodule QuizGameWeb.Support.Router do
  @moduledoc "This project's router helpers."
  use QuizGameWeb, :verified_routes

  @typedoc "The contexts available for route matching."
  @type context :: :base | :quizzes | :users

  @typedoc "The actions available in the base context."
  @type base_action :: :root | :contact_us | :privacy_policy | :terms_of_use

  @typedoc "Generic dead view CRUD actions"
  @type dead_crud_action :: :index | :new | :create | :show

  @typedoc "Generic live view CRUD actions"
  @type live_crud_action :: :index | :show | :new | :edit

  @doc """
  Match against a route with no URL parameters.

  ## Examples

      iex> route(:users, :login)
      "/users/login"
  """

  @spec route(context, atom()) :: String.t()
  def route(context, action), do: route(context, action, [])

  @doc """
  Match against a route that contains a given set of URL parameters.

  ## Examples

      iex> route(:users, :email_verify_confirm, token: 123)
      "/users/confirm/email/123"
  """

  @spec route(context, atom(), keyword()) :: String.t()
  def route(context, action, opts)

  @spec route(:base, base_action, keyword()) :: String.t()
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
      :take -> ~p"/quizzes/#{opts[:quiz_id]}/take"
    end
  end

  def route(:quizzes_cards, action, opts) do
    case action do
      :index ->
        ~p"/quizzes/#{opts[:quiz_id]}/cards"

      :new ->
        ~p"/quizzes/#{opts[:quiz_id]}/cards/new"

      :create ->
        ~p"/quizzes/#{opts[:quiz_id]}/cards"

      :show ->
        ~p"/quizzes/#{opts[:quiz_id]}/cards/#{opts[:card_id]}"

      :edit ->
        ~p"/quizzes/#{opts[:quiz_id]}/cards/#{opts[:card_id]}/edit"

      n when n in [:show, :update, :delete] ->
        ~p"/quizzes/#{opts[:quiz_id]}/cards/#{opts[:card_id]}"
    end
  end

  # credo:disable-for-next-line
  def route(:users, action, opts) do
    case action do
      # auth
      :register -> ~p"/users/register"
      :email_verify_solicit -> ~p"/users/verify/email"
      :email_verify_confirm -> ~p"/users/verify/email/#{opts[:token]}"
      :login -> ~p"/users/login"
      :logout_confirm -> ~p"/users/logout"
      :logout -> ~p"/users/logout"
      :password_reset_solicit -> ~p"/users/reset-password"
      :password_reset_confirm -> ~p"/users/reset-password/#{opts[:token]}"
      # crud
      :show -> ~p"/users/me"
      :settings -> ~p"/users/me/edit"
      :email_update_solicit -> ~p"/users/me/edit/email"
      :email_update_confirm -> ~p"/users/me/edit/email/confirm/#{opts[:token]}"
      :password_update -> ~p"/users/me/edit/password"
      :delete_confirm -> ~p"/users/me/delete"
      :delete -> ~p"/users/me/delete"
      # quizzes
      :quizzes_index -> ~p"/users/me/quizzes"
      :quizzes_taken_index -> ~p"/users/me/quizzes/taken"
    end
  end

  @doc """
  Converts params to a query string.

  ## Examples

      iex> query_string(hello: "world")
      "?hello=world"
  """
  @spec query_string(keyword()) :: String.t()
  def query_string(params) do
    "?#{URI.encode_query(params)}"
  end
end
