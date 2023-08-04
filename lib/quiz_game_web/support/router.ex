defmodule QuizGameWeb.Support.Router do
  @moduledoc """
  This project's route path helpers.
  """

  @doc """
  Given a context name, a route name, and optional params, produce the matching URL.

  ## Examples

      iex> path("users", confirmation, token: 123)
  """
  use QuizGameWeb, :verified_routes

  def route("base", route_name) do
    case route_name do
      :root -> ~p"/"
      :contact_us -> ~p"/contact-us"
      :privacy_policy -> ~p"/privacy-policy"
      :terms_of_use -> ~p"/terms-of-use"
    end
  end

  def route(context_name, route_name, params \\ [])

  def route("quizzes", route_name, params) do
    case route_name do
      :index -> ~p"/quizzes"
      :new -> ~p"/quizzes/new"
      :create -> ~p"/quizzes"
      :edit -> ~p"/quizzes/#{params[:quiz_id]}/edit"
      n when n in [:show, :update, :delete] -> ~p"/quizzes/#{params[:quiz_id]}"
    end
  end

  # credo:disable-for-next-line
  def route("users", route_name, params) do
    case route_name do
      # auth
      :registration -> ~p"/users/register"
      :confirmation_instructions -> ~p"/users/confirm/email"
      :confirmation -> ~p"/users/confirm/email/#{params[:token]}"
      :login -> ~p"/users/login"
      :logout -> ~p"/users/logout"
      :forgot_password -> ~p"/users/reset-password"
      :reset_password -> ~p"/users/reset-password/#{params[:token]}"
      # crud
      :show -> ~p"/users/me"
      :settings -> ~p"/users/me/update"
      :update_email -> ~p"/users/me/update/email"
      :update_email_confirm -> ~p"/users/me/update/email/confirm/#{params[:token]}"
      :update_password -> ~p"/users/me/update/password"
      :delete_confirm -> ~p"/users/me/delete"
      :delete -> ~p"/users/me/delete"
    end
  end
end
