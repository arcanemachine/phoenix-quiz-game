defmodule QuizGame.Quizzes do
  @moduledoc "The Quizzes context."

  import Ecto.Query, warn: false

  alias QuizGame.Repo
  alias QuizGame.Quizzes.{Card, Quiz}

  @doc """
  Returns the list of quizzes.

  ## Examples

      iex> list_quizzes()
      [%Quiz{}, ...]

  """
  def list_quizzes do
    Repo.all(Quiz)
  end

  @doc """
  Gets a single quiz.

  Raises `Ecto.NoResultsError` if the Quiz does not exist.

  ## Examples

      iex> get_quiz!(123)
      %Quiz{}

      iex> get_quiz!(456)
      ** (Ecto.NoResultsError)

  """
  def get_quiz!(id), do: Repo.get!(Quiz, id)

  @doc """
  Creates a quiz.

  ## Examples

      iex> create_quiz(changeset)
      {:ok, %Quiz{}}

      iex> create_quiz(invalid_changeset)
      {:error, %Ecto.Changeset{}}

  """
  def create_quiz(%Ecto.Changeset{} = changeset) do
    changeset |> Repo.insert()
  end

  @doc """
  Updates a quiz.

  ## Examples

      iex> update_quiz(changeset)
      {:ok, %Quiz{}}

      iex> update_quiz(invalid_changeset)
      {:error, %Ecto.Changeset{}}

  """
  def update_quiz(%Ecto.Changeset{} = changeset) do
    changeset |> Repo.update()
  end

  @doc """
  Deletes a quiz.

  ## Examples

      iex> delete_quiz(quiz)
      {:ok, %Quiz{}}

      iex> delete_quiz(quiz)
      {:error, %Ecto.Changeset{}}

  """
  def delete_quiz(%Quiz{} = quiz) do
    Repo.delete(quiz)
  end

  @doc """
  Returns the list of cards.

  ## Examples

      iex> list_cards()
      [%Card{}, ...]

  """
  def list_cards do
    Repo.all(Card)
  end

  @doc """
  Gets a single card.

  Raises `Ecto.NoResultsError` if the Card does not exist.

  ## Examples

      iex> get_card!(123)
      %Card{}

      iex> get_card!(456)
      ** (Ecto.NoResultsError)

  """
  def get_card!(id), do: Repo.get!(Card, id)

  # @doc """
  # Creates a card.

  # ## Examples

  #     iex> create_card(%{field: value})
  #     {:ok, %Card{}}

  #     iex> create_card(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def create_card(attrs \\ %{}) do
  #   %Card{}
  #   |> Card.changeset_unsafe(attrs)
  #   |> Repo.insert()
  # end

  @doc """
  Creates a card.

  ## Examples

      iex> create_card(changeset)
      {:ok, %Card{}}

      iex> create_card(invalid_changeset)
      {:error, %Ecto.Changeset{}}

  """
  def create_card(%Ecto.Changeset{} = changeset) do
    changeset |> Repo.insert()
  end

  # @doc """
  # Updates a card.

  # ## Examples

  #     iex> update_card(card, %{field: new_value})
  #     {:ok, %Card{}}

  #     iex> update_card(card, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_card(%Card{} = card, attrs) do
  #   card
  #   |> Card.changeset_unsafe(attrs)
  #   |> Repo.update()
  # end

  @doc """
  Updates a card.

  ## Examples

      iex> update_card(changeset)
      {:ok, %Card{}}

      iex> update_card(invalid_changeset)
      {:error, %Ecto.Changeset{}}

  """
  def update_card(changeset) do
    changeset |> Repo.update()
  end

  @doc """
  Deletes a card.

  ## Examples

      iex> delete_card(card)
      {:ok, %Card{}}

      iex> delete_card(card)
      {:error, %Ecto.Changeset{}}

  """
  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking card changes.

  # ## Examples

  #     iex> change_card(card)
  #     %Ecto.Changeset{data: %Card{}}

  # """
  # def change_card(%Card{} = card, attrs \\ %{}) do
  #   Card.changeset(card, attrs)
  # end
end
