defmodule QuizGame.QuizzesTest do
  @moduledoc false
  use QuizGame.DataCase
  alias QuizGame.Quizzes
  alias QuizGame.Quizzes.Quiz
  import QuizGame.TestSupport.QuizzesFixtures

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
      valid_attrs = %{name: "some name"}

      assert {:ok, %Quiz{} = quiz} = Quizzes.create_quiz(valid_attrs)
      assert quiz.name == "some name"
    end

    test "create_quiz/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quizzes.create_quiz(@invalid_attrs)
    end

    test "update_quiz/2 with valid data updates the quiz" do
      quiz = quiz_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Quiz{} = quiz} = Quizzes.update_quiz(quiz, update_attrs)
      assert quiz.name == "some updated name"
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
    alias QuizGame.Quizzes.Card

    import QuizGame.QuizzesFixtures

    @invalid_attrs %{format: nil, image: nil, question: nil, answers: nil}

    test "list_cards/0 returns all cards" do
      card = card_fixture()
      assert Quizzes.list_cards() == [card]
    end

    test "get_card!/1 returns the card with given id" do
      card = card_fixture()
      assert Quizzes.get_card!(card.id) == card
    end

    test "create_card/1 with valid data creates a card" do
      valid_attrs = %{format: :multiple_choice, image: "some image", question: "some question", answers: ["option1", "option2"]}

      assert {:ok, %Card{} = card} = Quizzes.create_card(valid_attrs)
      assert card.format == :multiple_choice
      assert card.image == "some image"
      assert card.question == "some question"
      assert card.answers == ["option1", "option2"]
    end

    test "create_card/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Quizzes.create_card(@invalid_attrs)
    end

    test "update_card/2 with valid data updates the card" do
      card = card_fixture()
      update_attrs = %{format: :true_or_false, image: "some updated image", question: "some updated question", answers: ["option1"]}

      assert {:ok, %Card{} = card} = Quizzes.update_card(card, update_attrs)
      assert card.format == :true_or_false
      assert card.image == "some updated image"
      assert card.question == "some updated question"
      assert card.answers == ["option1"]
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
end
