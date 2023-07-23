defmodule QuizGame.Users.UserNotifier do
  @moduledoc """
  The UserNotifier context.
  """

  import Swoosh.Email

  alias QuizGame.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"QuizGame", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Welcome to #{Application.get_env(:quiz_game, :project_name)}!", """
    Welcome to #{Application.get_env(:quiz_game, :project_name)}!

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
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

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
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
end
