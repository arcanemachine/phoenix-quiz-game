defmodule QuizGameWeb.Support.Router do
  @moduledoc "This project's router helpers."

  use QuizGameWeb, :verified_routes

  @typedoc "The contexts available for route matching."
  @type context :: :core | :dev | :quizzes | :users

  @typedoc "The actions available in the core context."
  @type core_action :: :root | :contact_us | :privacy_policy | :terms_of_use

  @typedoc "The actions available in the dev context."
  @type dev_action :: :component_showcase

  @typedoc "Generic dead view CRUD actions"
  @type dead_crud_action :: :index | :new | :create | :show

  @typedoc "Generic live view CRUD actions"
  @type live_crud_action :: :index | :show | :new | :edit

  @doc """
  Converts params to a query string.

  `params` may be any enumerable supported by `URI.encode_query/1` (e.g. keyword list, map).

  If `params` is empty, an empty string will be returned.

  ## Examples

      iex> QuizGameWeb.Support.Router.query_string(%{})
      ""

      iex> QuizGameWeb.Support.Router.query_string(hello: "world")
      "?hello=world"

      iex> QuizGameWeb.Support.Router.query_string(%{"hello" => "world"})
      "?hello=world"
  """
  @spec query_string(Enum.t()) :: String.t()
  def query_string(params) do
    if Enum.empty?(params), do: "", else: "?#{URI.encode_query(params)}"
  end

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

      iex> route(:users, :verify_email_confirm, token: 123)
      "nusers/verify/email/123"
  """

  @spec route(context, atom(), keyword()) :: String.t()
  def route(context, action, params)

  @spec route(:core, core_action, keyword()) :: String.t()
  def route(:core, action, _params) do
    case action do
      :root -> ~p"/"
      :contact_us -> ~p"/contact-us"
      :privacy_policy -> ~p"/privacy-policy"
      :terms_of_use -> ~p"/terms-of-use"
    end
  end

  @spec route(:dev, dev_action, keyword()) :: String.t()
  def route(:dev, action, _params) do
    case action do
      :component_showcase -> "/dev/component-showcase"
    end
  end

  # credo:disable-for-next-line
  def route(:quizzes, action, params) do
    case action do
      :index -> ~p"/quizzes"
      :index_subject -> ~p"/quizzes/subjects/#{Keyword.fetch!(params, :subject)}"
      :new -> ~p"/quizzes/new"
      :new_random -> ~p"/quizzes/random"
      :create -> ~p"/quizzes/new"
      :edit -> ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/update"
      :update -> ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/update"
      n when n in [:show, :delete] -> ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}"
      :take -> ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/take"
      :take_random -> ~p"/quizzes/random/take"
      :stats -> ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/stats"
    end
  end

  def route(:quizzes_cards, action, params) do
    case action do
      :index ->
        ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards"

      :new ->
        ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards/new"

      :create ->
        ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards"

      :show ->
        ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards/#{Keyword.fetch!(params, :card_id)}"

      :edit ->
        ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards/#{Keyword.fetch!(params, :card_id)}/update"

      n when n in [:show, :update, :delete] ->
        ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards/#{Keyword.fetch!(params, :card_id)}"
    end
  end

  def route(:quizzes_records, action, params) do
    case action do
      :index -> ~p"/quizzes/#{Keyword.fetch!(params, :quiz_id)}/records"
    end
  end

  # credo:disable-for-next-line
  def route(:users, action, params) do
    case action do
      # auth
      :register -> ~p"/users/register"
      :register_success -> ~p"/users/register/success"
      :login -> ~p"/users/login"
      :logout_confirm -> ~p"/users/logout"
      :logout -> ~p"/users/logout"
      :reset_password_solicit -> ~p"/users/reset/password"
      :reset_password_confirm -> ~p"/users/reset/password/#{Keyword.fetch!(params, :token)}"
      :verify_email_solicit -> ~p"/users/verify/email"
      :verify_email_confirm -> ~p"/users/verify/email/#{Keyword.fetch!(params, :token)}"
      # crud
      :show -> ~p"/users/me"
      :settings -> ~p"/users/me/update"
      :update_display_name -> ~p"/users/me/update/display-name"
      :update_email_solicit -> ~p"/users/me/update/email"
      :update_email_confirm -> ~p"/users/me/update/email/#{Keyword.fetch!(params, :token)}"
      :update_password -> ~p"/users/me/update/password"
      :delete_confirm -> ~p"/users/me/delete"
      :delete -> ~p"/users/me/delete"
      # quizzes
      :quizzes_index -> ~p"/users/me/quizzes"
      :records_index -> ~p"/users/me/quizzes/records"
    end
  end
end
