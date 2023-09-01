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

      iex> create_quiz(%{name: "some name", kind: :general, user_id: 123}, unsafe: true)
      {:ok, %Card{}}

      iex> create_quiz(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_quiz(attrs \\ %{}, opts \\ [unsafe: false]) do
    if !opts[:unsafe], do: raise("This function must called with the option `unsafe: true`.")

    %Quiz{}
    |> Quiz.unsafe_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a quiz.

  To allow modification of non-user-editable fields, pass the option `unsafe: true`.

  ## Examples

      iex> update_quiz(quiz, %{field: new_value})
      {:ok, %Quiz{}}

      iex> update_quiz(quiz, %{user_id: 123}, unsafe: true)
      {:ok, %Quiz{}}

      iex> update_quiz(quiz, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_quiz(%Quiz{} = quiz, attrs, opts \\ [unsafe: false]) do
    if opts[:unsafe] do
      quiz
      |> Quiz.unsafe_changeset(attrs)
      |> Repo.update()
    else
      quiz
      |> Quiz.changeset(attrs)
      |> Repo.update()
    end
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
  Returns an `%Ecto.Changeset{}` for tracking quiz changes.

  ## Examples

      iex> change_quiz(quiz)
      %Ecto.Changeset{data: %Quiz{}}

  """
  def change_quiz(%Quiz{} = quiz, attrs \\ %{}) do
    Quiz.changeset(quiz, attrs)
  end

  @doc "Returns the number of cards associated with a given quiz."
  def quiz_card_count(%Quiz{} = quiz) do
    Repo.one!(from c in Card, where: c.quiz_id == ^quiz.id, select: count(c.id))
  end

  @doc """
  Returns the list of cards.

  # ## Examples

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

  @doc """
  Creates a card.

  ## Examples

      iex> create_card(%{
          quiz_id: 123,
          format: :text_entry,
          question: "some question",
          correct_answer: "some correct answer"
        },
        unsafe: true
      )
      {:ok, %Card{}}

      iex> create_card(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_card(attrs \\ %{}, opts \\ [unsafe: false]) do
    if !opts[:unsafe], do: raise("This function must called with the option `unsafe: true`.")

    %Card{}
    |> Card.unsafe_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a card.

  ## Examples

      iex> update_card(card, %{field: new_value})
      {:ok, %Card{}}

      iex> update_card(card, %{field: new_value}, unsafe: true)
      {:ok, %Card{}}

      iex> update_card(card, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_card(%Card{} = card, attrs \\ %{}, opts \\ [unsafe: false]) do
    if opts[:unsafe] do
      card
      |> Card.unsafe_changeset(attrs)
      |> Repo.update()
    else
      card
      |> Card.changeset(attrs)
      |> Repo.update()
    end
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking card changes.

  ## Examples

      iex> change_card(card)
      %Ecto.Changeset{data: %Card{}}

  """
  def change_card(%Card{} = card, attrs \\ %{}) do
    Card.changeset(card, attrs)
  end

  alias QuizGame.Quizzes.QuizRecord

  @doc """
  Returns the list of quiz_records.

  ## Examples

      iex> list_quiz_records()
      [%QuizRecord{}, ...]

  """
  def list_quiz_records do
    Repo.all(QuizRecord)
  end

  @doc """
  Gets a single quiz_record.

  Raises `Ecto.NoResultsError` if the Quiz record does not exist.

  ## Examples

      iex> get_quiz_record!(123)
      %QuizRecord{}

      iex> get_quiz_record!(456)
      ** (Ecto.NoResultsError)

  """
  def get_quiz_record!(id), do: Repo.get!(QuizRecord, id)

  @doc """
  Creates a quiz_record.

  ## Examples

      iex> create_quiz_record(%{field: value})
      {:ok, %QuizRecord{}}

      iex> create_quiz_record(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_quiz_record(attrs \\ %{}) do
    %QuizRecord{}
    |> QuizRecord.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a quiz_record.

  ## Examples

      iex> update_quiz_record(quiz_record, %{field: new_value})
      {:ok, %QuizRecord{}}

      iex> update_quiz_record(quiz_record, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_quiz_record(%QuizRecord{} = quiz_record, attrs) do
    quiz_record
    |> QuizRecord.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a quiz_record.

  ## Examples

      iex> delete_quiz_record(quiz_record)
      {:ok, %QuizRecord{}}

      iex> delete_quiz_record(quiz_record)
      {:error, %Ecto.Changeset{}}

  """
  def delete_quiz_record(%QuizRecord{} = quiz_record) do
    Repo.delete(quiz_record)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking quiz_record changes.

  ## Examples

      iex> change_quiz_record(quiz_record)
      %Ecto.Changeset{data: %QuizRecord{}}

  """
  def change_quiz_record(%QuizRecord{} = quiz_record, attrs \\ %{}) do
    QuizRecord.changeset(quiz_record, attrs)
  end
end
