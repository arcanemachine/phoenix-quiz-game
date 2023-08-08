defmodule QuizGame.Users.UserAdmin do
  @moduledoc "The Kaffy admin configuration for the User schema."

  def index(_) do
    [
      username: nil,
      id: nil,
      email: nil,
      inserted_at: %{name: "Registered"},
      confirmed_at: nil
    ]
  end

  def form_fields(_) do
    [
      id: %{update: :hidden},
      username: %{create: :hidden},
      email: %{create: :hidden},
      confirmed_at: %{create: :hidden}
    ]
  end
end
