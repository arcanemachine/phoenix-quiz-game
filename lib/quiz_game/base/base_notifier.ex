defmodule QuizGame.Base.BaseNotifier do
  @moduledoc "The base notifier context."

  import Swoosh.Email

  alias QuizGame.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
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

  @doc "Deliver contact form email."
  def deliver_contact_us_form(sender_name, sender_email, sender_message) do
    deliver(
      Application.get_env(:quiz_game, :email_recipient_contact_form),
      "#{Application.get_env(:quiz_game, :project_name)} - Contact Form Submitted",
      """
      Name: #{sender_name}

      Email: #{sender_email}

      Message: #{sender_message}
      """
    )
  end
end
