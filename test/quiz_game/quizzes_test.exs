defmodule QuizGame.QuizzesTest do
  @moduledoc false
  use QuizGame.DataCase
  import QuizGame.TestSupport.Fixtures.{Quizzes, Users}
  alias QuizGame.Quizzes
  alias QuizGame.Quizzes.{Card, Quiz, Record}

  describe "quizzes" do
    @invalid_attrs %{name: nil}

    test "list_quizzes/0 returns all quizzes" do
      quiz = quiz_fixture()
      assert Quizzes.list_quizzes() == [quiz]
    end

    test "get_quiz!/1 returns the quiz with given id" do
      quiz = quiz_fixture()
      assert Quizzes.get_quiz!(quiz.id) == quiz
    end

    test "create_quiz/1 with valid data creates a quiz" do
      valid_attrs = %{user_id: user_fixture().id, name: "some name", subject: "other"}

      assert {:ok, %Quiz{} = quiz} = Quizzes.create_quiz(valid_attrs, unsafe: true)
      assert quiz.name == "some name"
    end

    test "create_quiz/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quizzes.create_quiz(@invalid_attrs, unsafe: true)
    end

    test "update_quiz/2 with valid data updates the quiz" do
      quiz = quiz_fixture()
      update_attrs = %{name: "updated name"}

      assert {:ok, %Quiz{} = quiz} = Quizzes.update_quiz(quiz, update_attrs)
      assert quiz.name == "updated name"
    end

    test "update_quiz/2 with invalid data returns error changeset" do
      quiz = quiz_fixture()
      assert {:error, %Ecto.Changeset{}} = Quizzes.update_quiz(quiz, @invalid_attrs)
      assert quiz == Quizzes.get_quiz!(quiz.id)
    end

    test "delete_quiz/1 deletes the quiz" do
      quiz = quiz_fixture()
      assert {:ok, %Quiz{}} = Quizzes.delete_quiz(quiz)
      assert_raise Ecto.NoResultsError, fn -> Quizzes.get_quiz!(quiz.id) end
    end

    test "change_quiz/1 returns a quiz changeset" do
      quiz = quiz_fixture()
      assert %Ecto.Changeset{} = Quizzes.change_quiz(quiz)
    end
  end

  describe "cards" do
    @invalid_attrs %{format: nil, question: nil, answers: nil}

    # test "card_list/0 returns all cards" do
    #   card = card_fixture()
    #   assert Quizzes.card_list() == [card]
    # end

    test "get_card!/1 returns the card with given id" do
      card = card_fixture()
      assert Quizzes.get_card!(card.id) == card
    end

    test "create_card/1 with valid data creates a card" do
      user = user_fixture()
      quiz = quiz_fixture(user_id: user.id)

      valid_attrs = %{
        user_id: user.id,
        quiz_id: quiz.id,
        format: :text_entry,
        # image: "some image",
        question: "some question",
        correct_answer: "some answer"
      }

      assert {:ok, %Card{} = card} = Quizzes.create_card(valid_attrs, unsafe: true)
      assert card.quiz_id == quiz.id
      assert card.format == :text_entry
      # assert card.image == "some image"
      assert card.question == "some question"
      assert card.correct_answer == "some answer"
    end

    test "create_card/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quizzes.create_card(@invalid_attrs, unsafe: true)
    end

    test "update_card/2 with valid data updates the card" do
      card = card_fixture()

      update_attrs = %{
        format: :text_entry,
        # image: "updated image",
        question: "updated question",
        correct_answer: "updated answer"
      }

      assert {:ok, %Card{} = card} = Quizzes.update_card(card, update_attrs)
      assert card.format == :text_entry
      # assert card.image == "updated image"
      assert card.question == "updated question"
      assert card.correct_answer == "updated answer"
    end

    test "update_card/2 with invalid data returns error changeset" do
      card = card_fixture()
      assert {:error, %Ecto.Changeset{}} = Quizzes.update_card(card, @invalid_attrs)
      assert card == Quizzes.get_card!(card.id)
    end

    test "delete_card/1 deletes the card" do
      card = card_fixture()
      assert {:ok, %Card{}} = Quizzes.delete_card(card)
      assert_raise Ecto.NoResultsError, fn -> Quizzes.get_card!(card.id) end
    end

    test "change_card/1 returns a card changeset" do
      card = card_fixture()
      assert %Ecto.Changeset{} = Quizzes.change_card(card)
    end
  end

  describe "records" do
    @invalid_attrs %{date: nil, card_count: nil, score: nil}

    test "list_records/0 returns all records" do
      record = record_fixture()
      assert Quizzes.list_records() == [record]
    end

    test "get_record!/1 returns the record with given id" do
      record = record_fixture()
      assert Quizzes.get_record!(record.id) == record
    end

    test "create_record/1 with valid data creates a record" do
      quiz = quiz_fixture()
      valid_attrs = %{quiz_id: quiz.id, display_name: "some name", card_count: 42, score: 42}

      assert {:ok, %Record{} = record} = Quizzes.create_record(valid_attrs)
      assert record.quiz_id == quiz.id
      assert record.display_name == "some name"
      assert record.card_count == 42
      assert record.score == 42
    end

    test "create_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quizzes.create_record(@invalid_attrs)
    end

    test "update_record/2 with valid data updates the record" do
      record = record_fixture()
      update_attrs = %{display_name: "updated name", card_count: 43, score: 43}

      assert {:ok, %Record{} = record} =
               Quizzes.update_record(record, update_attrs)

      assert record.card_count == 43
      assert record.score == 43
    end

    test "update_record/2 with invalid data returns error changeset" do
      record = record_fixture()
      assert {:error, %Ecto.Changeset{}} = Quizzes.update_record(record, @invalid_attrs)
      assert record == Quizzes.get_record!(record.id)
    end

    test "delete_record/1 deletes the record" do
      record = record_fixture()
      assert {:ok, %Record{}} = Quizzes.delete_record(record)
      assert_raise Ecto.NoResultsError, fn -> Quizzes.get_record!(record.id) end
    end

    test "change_record/1 returns a record changeset" do
      record = record_fixture()
      assert %Ecto.Changeset{} = Quizzes.change_record(record)
    end
  end
end
