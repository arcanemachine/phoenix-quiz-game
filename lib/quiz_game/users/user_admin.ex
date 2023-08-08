defmodule QuizGame.Users.UserAdmin do
  @moduledoc "The Kaffy admin configuration for the User schema."

  def index(_) do
    [
      username: nil,
      id: nil,
      email: nil,
      is_admin: %{choices: [{"Yes", true}, {"No", false}]},
      inserted_at: %{name: "Registered"},
      confirmed_at: nil
    ]
  end

  def form_fields(_) do
    [
      id: %{update: :hidden},
      username: %{create: :hidden},
      email: %{create: :hidden},
      is_admin: %{choices: [{"Yes", true}, {"No", false}]},
      confirmed_at: %{create: :hidden}
    ]
  end
end
