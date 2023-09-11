defmodule QuizGameWeb.Support.Router do
  @moduledoc "This project's router helpers."

  @typedoc "The contexts available for route matching."
  @type context :: :base | :quizzes | :users

  @typedoc "The actions available in the base context."
  @type base_action :: :root | :contact_us | :privacy_policy | :terms_of_use

  @typedoc "Generic dead view CRUD actions"
  @type dead_crud_action :: :index | :new | :create | :show

  @typedoc "Generic live view CRUD actions"
  @type live_crud_action :: :index | :show | :new | :edit

  @doc """
  Converts params to a query string.

  `params` may be any enumerable supported by `URI.encode_query/1` (e.g. keyword list, map).

  If `params` is empty, an empty string will be returned.

  ## Examples

      iex> query_string(hello: "world")
      "?hello=world"

      iex> query_string(%{"hello" => "world"})
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

  @spec route(:base, base_action, keyword()) :: String.t()
  def route(:base, action, _params) do
    case action do
      :root -> "/"
      :contact_us -> "/contact-us"
      :privacy_policy -> "/privacy-policy"
      :terms_of_use -> "/terms-of-use"
    end
  end

  def route(:quizzes, action, params) do
    case action do
      :index -> "/quizzes"
      :index_subject -> "/quizzes/subjects/#{Keyword.fetch!(params, :subject)}"
      :new -> "/quizzes/new"
      :create -> "/quizzes/new"
      :edit -> "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/update"
      :update -> "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/update"
      n when n in [:show, :delete] -> "/quizzes/#{Keyword.fetch!(params, :quiz_id)}"
      :take -> "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/take"
      :stats -> "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/stats"
    end
  end

  def route(:quizzes_cards, action, params) do
    case action do
      :index ->
        "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards"

      :new ->
        "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards/new"

      :create ->
        "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards"

      :show ->
        "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards/#{Keyword.fetch!(params, :card_id)}"

      :edit ->
        "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards/#{Keyword.fetch!(params, :card_id)}/update"

      n when n in [:show, :update, :delete] ->
        "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/cards/#{Keyword.fetch!(params, :card_id)}"
    end
  end

  def route(:quizzes_records, action, params) do
    case action do
      :index ->
        "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/records"

      :show ->
        "/quizzes/#{Keyword.fetch!(params, :quiz_id)}/records/#{Keyword.fetch!(params, :record_id)}"
    end
  end

  # credo:disable-for-next-line
  def route(:users, action, params) do
    case action do
      # auth
      :register -> "/users/register"
      :login -> "/users/login"
      :logout_confirm -> "/users/logout"
      :logout -> "/users/logout"
      :reset_password_solicit -> "/users/reset/password"
      :reset_password_confirm -> "/users/reset/password/#{Keyword.fetch!(params, :token)}"
      :verify_email_solicit -> "/users/verify/email"
      :verify_email_confirm -> "/users/verify/email/#{Keyword.fetch!(params, :token)}"
      # crud
      :show -> "/users/me"
      :settings -> "/users/me/update"
      :update_display_name -> "/users/me/update/display-name"
      :update_email_solicit -> "/users/me/update/email"
      :update_email_confirm -> "/users/me/update/email/#{Keyword.fetch!(params, :token)}"
      :update_password -> "/users/me/update/password"
      :delete_confirm -> "/users/me/delete"
      :delete -> "/users/me/delete"
      # quizzes
      :quizzes_index -> "/users/me/quizzes"
      :records_index -> "/users/me/quizzes/records"
    end
  end
end
