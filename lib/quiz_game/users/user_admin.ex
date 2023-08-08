defmodule QuizGame.Users.UserAdmin do
  @moduledoc "The Kaffy admin configuration for the User schema."

  # TO-DO: don't let user modify their own admin status

  def index(_) do
    [
      username: nil,
      email: nil,
      is_admin: %{choices: [{"Yes", true}, {"No", false}]},
      inserted_at: %{name: "Registered"},
      confirmed_at: nil,
      id: nil
    ]
  end

  def form_fields(_) do
    [
      id: %{create: :readonly, update: :hidden},
      username: %{create: :hidden},
      email: %{create: :hidden},
      is_admin: %{choices: [{"Yes", true}, {"No", false}]},
      confirmed_at: %{create: :hidden}
    ]
  end
end
