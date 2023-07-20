defmodule QuizGameWeb.UserSessionController do
  use QuizGameWeb, :controller

  alias QuizGame.Users
  alias QuizGameWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, success_message) do
    %{"email" => email, "password" => password} = user_params

    if user = Users.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:success, success_message)
      |> UserAuth.login_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/login")
    end
  end

  def logout_confirm(conn, _params) do
    render(conn, :logout_confirm, page_title: "Confirm Logout")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:success, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
