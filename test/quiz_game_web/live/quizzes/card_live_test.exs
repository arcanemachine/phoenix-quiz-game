defmodule QuizGameWeb.Quizzes.CardLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{Assertions, QuizzesFixtures, UsersFixtures}

  @create_attrs %{
    format: :text_entry,
    # image: "some image",
    question: "some question",
    correct_answer: "some answer"
  }
  @update_attrs %{
    format: :text_entry,
    # image: "updated image",
    question: "updated question",
    correct_answer: "updated answer"
  }
  @invalid_attrs %{
    format: nil,
    # image: nil,
    question: nil
    # correct_answer: nil # choice will not appear
  }

  setup do
    user = user_fixture()
    quiz = quiz_fixture(user_id: user.id)
    card = card_fixture(user_id: user.id, quiz_id: quiz.id)
    %{user: user, card: card, quiz: quiz}
  end

  describe ":index" do
    def get_test_url(quiz_id), do: route(:quizzes_cards, :index, quiz_id: quiz_id)

    test "lists all cards", %{conn: conn, card: card, user: user} do
      {:ok, _view, html} =
        conn
        |> login_user(user)
        |> live(get_test_url(card.quiz_id))

      assert html =~ "Question List"
      assert html =~ card.question
    end

    test "saves new card", %{conn: conn, user: user, quiz: quiz} do
      {:ok, view, _html} =
        conn
        |> login_user(user)
        |> live(get_test_url(quiz.id))

      assert view |> element("a", "New Question") |> render_click() =~
               "New Question"

      assert_patch(view, ~p"/quizzes/cards/new")

      assert view
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "is required"

      assert view
             |> form("#card-form", card: @create_attrs)
             |> render_submit()

      assert_patch(view, ~p"/quizzes/cards")
      # assert_patch(view, route(:quizzes_cards, :index, quiz_id: quiz.id))

      html = render(view)
      assert html =~ "Question created successfully"
      assert html =~ "some image"
    end

    test "updates card in listing", %{conn: conn, card: card} do
      {:ok, view, _html} = live(conn, ~p"/quizzes/cards")

      assert view |> element("#cards-#{card.id} a", "Edit") |> render_click() =~
               "Edit Question"

      assert_patch(view, ~p"/quizzes/cards/#{card}/edit")

      assert view
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "is required"

      assert view
             |> form("#card-form", card: @update_attrs)
             |> render_submit()

      assert_patch(view, ~p"/quizzes/cards")

      html = render(view)
      assert html =~ "Question updated successfully"
      assert html =~ "some updated image"
    end
  end

  describe ":show" do
    def get_test_url(quiz_id, card_id),
      do: route(:quizzes_cards, :show, quiz_id: quiz_id, card_id: card_id)

    test "displays card", %{conn: conn, user: user, card: card} do
      {:ok, _view, html} =
        conn
        |> login_user(user)
        |> live(get_test_url(card.quiz_id, card.id))

      assert html =~ "Question Info"
      # assert html =~ card.image
    end

    test "deletes card in listing", %{conn: conn, user: user, card: card} do
      success_url = route(:quizzes_cards, :index, quiz_id: card.quiz_id)

      {:ok, view, _html} =
        conn
        |> login_user(user)
        |> live(get_test_url(card.quiz_id, card.id))

      # delete the card
      view
      |> element("[data-test-id='delete-card']")
      |> render_click()

      # view redirects to expected route
      refute view
             |> assert_redirected(success_url)
             # index no longer contains expected value
             |> render()
             |> html_has_content(card.question)
    end
  end

  describe ":edit" do
    def get_test_url(quiz_id, card_id) do
      route(:quizzes_cards, :edit, quiz_id: quiz_id, card_id: card_id)
    end

    def get_success_url(quiz_id), do: route(:quizzes_cards, :index, quiz_id: quiz_id)

    test "does not update card with invalid data", %{conn: conn, user: user, card: card} do
      edit_url = route(:quizzes_cards, :edit, quiz_id: card.quiz_id, card_id: card.id)

      {:ok, view, _html} =
        conn
        |> login_user(user)
        |> live(get_test_url(card.quiz_id, card.id))

      assert view
             |> element("a", "Edit this question")
             |> render_click() =~
               "Edit Question"

      assert_patch(view, edit_url)

      assert view
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~
               "is required"
    end

    test "updates card in modal", %{conn: conn, user: user, card: card} do
      edit_url = route(:quizzes_cards, :edit, quiz_id: card.quiz_id, card_id: card.id)
      success_url = route(:quizzes_cards, :show, quiz_id: card.quiz_id, card_id: card.id)

      {:ok, view, _html} =
        conn
        |> login_user(user)
        |> live(get_test_url(card.quiz_id, card.id))

      assert view
             |> element("a", "Edit this question")
             |> render_click() =~
               "Edit Question"

      assert_patch(view, edit_url)

      assert view
             |> form("#card-form", card: @update_attrs)
             |> render_submit()

      assert_patch(view, success_url)

      html = render(view)
      assert html =~ "Question updated successfully"
      # assert html =~ "some updated image"
    end
  end
end
