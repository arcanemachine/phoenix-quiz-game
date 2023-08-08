defmodule QuizGame.TestSupport.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the `QuizGame.Users` context.
  """

  alias QuizGame.Repo
  alias QuizGame.Users.User

  def unique_user_username, do: "user#{System.unique_integer()}"
  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      username: unique_user_username(),
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> QuizGame.Users.register_user()

    user
  end

  def grant_admin_permissions_to_user(%User{} = user) do
    changeset = Ecto.Changeset.change(user, %{is_admin: true})
    {:ok, updated_user} = Repo.update(changeset)

    updated_user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
