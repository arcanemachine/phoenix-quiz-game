defmodule QuizGame.Users.UserTokenAdmin do
  @moduledoc "The Kaffy admin configuration for the UserToken schema."

  def index(_) do
    [
      id: %{name: "ID"},
      context: nil,
      user_id: nil,
      sent_to: nil,
      inserted_at: nil
    ]
  end

  def form_fields(_) do
    [
      id: %{type: :text, create: :readonly, update: :readonly}
    ]
  end
end
