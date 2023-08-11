defmodule QuizGame.Users.UserNotifier do
  @moduledoc "The UserNotifier context."
  import Swoosh.Email
  alias QuizGame.Mailer

  defp deliver(recipient, subject, body) do
    # deliver email using the application mailer
    email =
      new()
      |> to(recipient)
      |> from(
        {Application.get_env(:quiz_game, :project_name), "no-reply@#{System.get_env("PHX_HOST")}"}
      )
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc "Send an email containing instructions to update a user's email address."
  def deliver_email_update_instructions(user, url) do
    deliver(
      user.email,
      "#{Application.get_env(:quiz_game, :project_name)} - Confirm New Email",
      """
      Confirm your new email address by visiting the URL below:

      #{url}

      If you didn't request this change, please ignore this.

      ---

      Thanks for using #{Application.get_env(:quiz_game, :project_name)}!
      """
    )
  end

  @doc "Send an email containing instructions for a user to their email address."
  def deliver_email_verify_instructions(user, url) do
    deliver(user.email, "Welcome to #{Application.get_env(:quiz_game, :project_name)}!", """
    Welcome to #{Application.get_env(:quiz_game, :project_name)}!

    You can confirm your email address by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.
    """)
  end

  @doc "Send an email containing instructions to reset a user's password."
  def deliver_password_reset_instructions(user, url) do
    deliver(
      user.email,
      "#{Application.get_env(:quiz_game, :project_name)} - Reset Your Password",
      """
      You can reset your password by visiting the URL below:

      #{url}

      If you didn't request this change, please ignore this email.

      ---

      Thanks for using #{Application.get_env(:quiz_game, :project_name)}!
      """
    )
  end
end
