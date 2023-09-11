defmodule QuizGameWeb.Quizzes.CardLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{QuizzesFixtures, UsersFixtures}

  @create_attrs %{
    question: "some question",
    format: :text_entry,
    # image: "some image",
    correct_answer: "some answer"
  }
  @update_attrs %{
    question: "updated question",
    format: :text_entry,
    # image: "updated image",
    correct_answer: "updated answer"
  }
  @invalid_attrs %{
    question: nil,
    format: nil
    # image: nil,
    # correct_answer: nil # do not pass this value if :format is null
  }

  def get_index_url(quiz_id), do: route(:quizzes_cards, :index, quiz_id: quiz_id)

  def get_new_url(quiz_id), do: route(:quizzes_cards, :new, quiz_id: quiz_id)

  def get_show_url(quiz_id, card_id),
    do: route(:quizzes_cards, :show, quiz_id: quiz_id, card_id: card_id)

  def get_edit_url(quiz_id, card_id) do
    route(:quizzes_cards, :edit, quiz_id: quiz_id, card_id: card_id)
  end

  setup do
    user = user_fixture()
    quiz = quiz_fixture(user_id: user.id)
    card = card_fixture(user_id: user.id, quiz_id: quiz.id)
    %{user: user, card: card, quiz: quiz}
  end

  describe ":index" do
    test "lists all cards", %{conn: conn, card: card, user: user} do
      {:ok, _view, html} = conn |> login_user(user) |> live(get_index_url(card.quiz_id))

      # template contains expected content
      assert html =~ "Question List"
      assert html =~ card.question
    end

    test "saves new card", %{conn: conn, user: user, quiz: quiz} do
      {:ok, view, _html} = conn |> login_user(user) |> live(get_index_url(quiz.id))

      # click event on expected element renders expected content
      assert view
             |> element("a", "Create new question")
             |> render_click() =~ "New Question"

      # redirects to expected route via live patch
      assert_patch(view, get_new_url(quiz.id))

      # attempt to submit form with invalid data
      assert view
             |> form("#card-form", card: @invalid_attrs)
             # change event renders expected form validation errors
             |> render_change() =~ "is required"

      # assign required field(s) so that conditional field(s) will be rendered
      assert view
             |> form("#card-form", card: %{format: @create_attrs[:format]})
             |> render_change()

      # submit form with valid data
      assert view |> form("#card-form", card: @create_attrs) |> render_submit()

      # redirects to expected route via live patch
      assert_patch(view, get_index_url(quiz.id))

      # template contains expected content
      html = render(view)
      assert html =~ "Question created successfully"
      # assert html =~ "some image"
    end
  end

  describe ":show" do
    test "displays expected card", %{conn: conn, user: user, card: card} do
      {:ok, _view, html} = conn |> login_user(user) |> live(get_show_url(card.quiz_id, card.id))

      # template contains expected content
      assert html =~ "Question Info"
      # assert html =~ card.image
    end

    test "updates expected card", %{conn: conn, user: user, card: card} do
      {:ok, view, _html} =
        conn
        |> login_user(user)
        |> live(get_show_url(card.quiz_id, card.id))

      # click event on expected element renders expected content
      assert view
             |> element("a", "Edit this question")
             |> render_click() =~ "Edit Question"

      # redirects to expected route via live patch
      assert_patch(view, get_edit_url(card.quiz_id, card.id))

      # attempt to submit form with invalid data
      assert view
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "is required"

      # assign required field(s) so that conditional field(s) will be rendered
      assert view
             |> form("#card-form", card: %{format: @update_attrs[:format]})
             |> render_change()

      # submit form with valid data
      assert view |> form("#card-form", card: @update_attrs) |> render_submit()

      # redirects to expected route via live patch
      assert_patch(view, get_show_url(card.quiz_id, card.id))

      # template contains expected content
      html = render(view)
      assert html =~ "Question updated successfully"
      # assert html =~ "some updated image"
    end
  end

  test "deletes expected card", %{conn: conn, user: user, card: card} do
    {:ok, view, _html} =
      conn |> login_user(user) |> live(get_show_url(card.quiz_id, card.id))

    # delete expected record
    view |> element("[data-test-id='delete-card']") |> render_click()

    # redirects to expected route
    view
    |> assert_redirected(
      get_index_url(card.quiz_id) <> query_string(%{"delete-question-success" => "1"})
    )

    # template does not contain expected content after redirect
    {:ok, _view, html_after_redirect} =
      conn |> login_user(user) |> live(get_index_url(card.quiz_id))

    refute html_after_redirect =~ card.question
  end
end
