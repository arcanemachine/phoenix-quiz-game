defmodule QuizGame.Users.User do
  @moduledoc "The user schema."
  use Ecto.Schema
  import Ecto.Changeset

  def display_name_length_max(), do: 24
  def username_length_min(), do: 3
  def username_length_max(), do: 32
  def email_length_max(), do: 160
  def password_length_min(), do: 8

  # max password length is 72 when using bcrypt
  def password_length_max(), do: 72

  schema "users" do
    # associations
    has_many :quizzes, QuizGame.Quizzes.Quiz
    has_many :records, QuizGame.Quizzes.Record

    # data
    field :username, :string
    field :display_name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true

    # attributes
    field :confirmed_at, :naive_datetime
    field :is_admin, :boolean, default: false

    # computed
    field :hashed_password, :string, redact: true

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username, :display_name, :email, :password])
    |> validate_username(opts)
    |> validate_display_name()
    |> validate_email(opts)
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  defp validate_display_name(changeset) do
    changeset
    |> validate_required([:display_name])
    |> update_change(:display_name, &String.trim/1)
    |> validate_length(:display_name, max: display_name_length_max())
  end

  defp validate_username(changeset, opts) do
    changeset
    |> validate_required([:username])
    |> validate_length(:username, min: username_length_min(), max: username_length_max())
    |> maybe_validate_unique_username(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "is not a valid email address")
    |> validate_length(:email, max: email_length_max())
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: password_length_min(), max: password_length_max())
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> validate_length(:password, max: password_length_max(), count: :bytes)
      # hash with bcrypt instead of `Ecto.Changeset.prepare_changes/2` for improved performance
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_username(changeset, opts) do
    if Keyword.get(opts, :validate_username, true) do
      changeset
      |> unsafe_validate_unique(:username, QuizGame.Repo)
      |> unique_constraint(:username)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, QuizGame.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc "A changeset for managing a user's display name."
  def display_name_changeset(quiz, attrs, _opts \\ []) do
    quiz
    |> cast(attrs, [:display_name])
    |> validate_display_name()
  end

  @doc "A changeset for managing a users's admin permissions."
  def is_admin_changeset(quiz, attrs, _opts \\ []) do
    quiz
    |> cast(attrs, [:is_admin])
    |> validate_required([:is_admin])
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset ->
        # changeset contains changed email
        changeset

      %{} = changeset ->
        # changeset does not contain changed email
        add_error(changeset, :email, "should be different than your current email")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%QuizGame.Users.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "should be your current password")
    end
  end
end
