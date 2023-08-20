defmodule QuizGameWeb.UserSessionController do
  use QuizGameWeb, :controller

  import QuizGameWeb.Support.Conn, only: [text_response: 3]
  import QuizGameWeb.Support.Router, only: [route: 2]

  alias QuizGame.Users
  alias QuizGameWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, route(:users, :settings))
    |> create(params, "Password updated successfully")
  end

  def create(conn, form_params) do
    # validate the captcha before finishing the login process
    if QuizGameWeb.Support.form_captcha_valid?(form_params) do
      create(conn, form_params, "Logged in successfully")
    else
      text_response(conn, 401, "You must complete the human test at the bottom of the form.")
    end
  end

  defp create(conn, %{"user" => user_params} = params, success_message) do
    %{"email" => email, "password" => password} = user_params

    if user = Users.get_user_by_email_and_password(email, password) do
      # if 'next' URL param exists, redirect to it
      conn =
        if "next" in Map.keys(params),
          do: conn |> put_session(:user_return_to, params["next"]),
          else: conn

      conn
      |> put_flash(:success, success_message)
      |> UserAuth.login_user(user, user_params)
    else
      # to prevent user enumeration attacks, don't disclose whether the email is registered
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: route(:users, :login))
    end
  end

  def logout_confirm(conn, _params) do
    render(conn, :logout_confirm, page_title: "Confirm Logout")
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:success, "Logged out successfully")
    |> UserAuth.logout_user()
  end

  def redirect_to_url_param_next() do
    quote do
    end
  end
end
