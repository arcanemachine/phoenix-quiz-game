defmodule QuizGameWeb.Support.Router do
  @moduledoc "This project's router helpers."

  use QuizGameWeb, :verified_routes

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

  @typep route_context :: :core | :dev | :quizzes | :quizzes_cards | :quizzes_records | :users
  @spec route(route_context, atom(), keyword()) :: String.t()
  def route(context, action, params \\ [])

  @doc """
  Match against a route that contains a given set of URL parameters.

  ## Examples

      iex> QuizGameWeb.Support.Router.route(:users, :verify_email_solicit)
      "/users/verify/email"

      iex> QuizGameWeb.Support.Router.route(:users, :verify_email_confirm, token: 123)
      "/users/verify/email/123"
  """

  # core
  def route(:core, :root, []), do: ~p"/"
  def route(:core, :contact_us, []), do: ~p"/contact-us"
  def route(:core, :privacy_policy, []), do: ~p"/privacy-policy"
  def route(:core, :terms_of_use, []), do: ~p"/terms-of-use"

  # dev
  def route(:dev, :component_showcase, _params), do: "/dev/component-showcase"

  # quizzes
  def route(:quizzes, :index, []), do: ~p"/quizzes"
  def route(:quizzes, :index_subject, subject: subject), do: ~p"/quizzes/subjects/#{subject}"
  def route(:quizzes, :new, []), do: ~p"/quizzes/create"
  def route(:quizzes, :create, []), do: ~p"/quizzes/create"
  def route(:quizzes, :show, quiz_id: quiz_id), do: ~p"/quizzes/#{quiz_id}"
  def route(:quizzes, :edit, quiz_id: quiz_id), do: ~p"/quizzes/#{quiz_id}/update"
  def route(:quizzes, :update, quiz_id: quiz_id), do: ~p"/quizzes/#{quiz_id}/update"
  def route(:quizzes, :delete, quiz_id: quiz_id), do: ~p"/quizzes/#{quiz_id}"
  def route(:quizzes, :take, quiz_id: quiz_id), do: ~p"/quizzes/#{quiz_id}/take"
  def route(:quizzes, :stats, quiz_id: quiz_id), do: ~p"/quizzes/#{quiz_id}/stats"
  def route(:quizzes, :new_random, []), do: ~p"/quizzes/random/create"
  def route(:quizzes, :take_random, []), do: ~p"/quizzes/random/take"

  # quizzes - card
  def route(:quizzes_cards, :index, quiz_id: quiz_id), do: ~p"/quizzes/#{quiz_id}/cards"
  def route(:quizzes_cards, :new, quiz_id: quiz_id), do: ~p"/quizzes/#{quiz_id}/cards/create"
  def route(:quizzes_cards, :create, quiz_id: quiz_id), do: ~p"/quizzes/#{quiz_id}/cards"

  def route(:quizzes_cards, :show, quiz_id: quiz_id, card_id: card_id),
    do: ~p"/quizzes/#{quiz_id}/cards/#{card_id}"

  def route(:quizzes_cards, :edit, quiz_id: quiz_id, card_id: card_id),
    do: ~p"/quizzes/#{quiz_id}/cards/#{card_id}/update"

  def route(:quizzes_cards, :update, quiz_id: quiz_id, card_id: card_id),
    do: ~p"/quizzes/#{quiz_id}/cards/#{card_id}"

  def route(:quizzes_cards, :delete, quiz_id: quiz_id, card_id: card_id),
    do: ~p"/quizzes/#{quiz_id}/cards/#{card_id}"

  # quizzes - record
  def route(:quizzes_records, :index, quiz_id: quiz_id), do: ~p"/quizzes/#{quiz_id}/records"

  # users
  def route(:users, :register, []), do: ~p"/users/register"
  def route(:users, :register_success, []), do: ~p"/users/register/success"
  def route(:users, :login, []), do: ~p"/users/login"
  def route(:users, :reset_password_solicit, []), do: ~p"/users/reset/password"
  def route(:users, :reset_password_confirm, token: token), do: ~p"/users/reset/password/#{token}"
  def route(:users, :verify_email_solicit, []), do: ~p"/users/verify/email"
  def route(:users, :verify_email_confirm, token: token), do: ~p"/users/verify/email/#{token}"
  def route(:users, :logout_confirm, []), do: ~p"/users/logout"
  def route(:users, :logout, []), do: ~p"/users/logout"
  def route(:users, :show, []), do: ~p"/users/me"
  def route(:users, :settings, []), do: ~p"/users/me/update"
  def route(:users, :update_display_name, []), do: ~p"/users/me/update/display-name"
  def route(:users, :update_email_solicit, []), do: ~p"/users/me/update/email"
  def route(:users, :update_email_confirm, token: token), do: ~p"/users/me/update/email/#{token}"
  def route(:users, :update_password, []), do: ~p"/users/me/update/password"
  def route(:users, :delete_confirm, []), do: ~p"/users/me/delete"
  def route(:users, :delete, []), do: ~p"/users/me/delete"
  def route(:users, :quizzes_index, []), do: ~p"/users/me/quizzes"
  def route(:users, :records_index, []), do: ~p"/users/me/quizzes/records"
end
