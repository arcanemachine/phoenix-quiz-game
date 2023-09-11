defmodule QuizGameWeb.Quizzes.CardLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{GenericTests, QuizzesFixtures, UsersFixtures}

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

  defp _get_card_index_url(quiz_id), do: route(:quizzes_cards, :index, quiz_id: quiz_id)

  defp _get_card_new_url(quiz_id), do: route(:quizzes_cards, :new, quiz_id: quiz_id)

  defp _get_card_show_url(quiz_id, card_id),
    do: route(:quizzes_cards, :show, quiz_id: quiz_id, card_id: card_id)

  defp _get_card_edit_url(quiz_id, card_id) do
    route(:quizzes_cards, :edit, quiz_id: quiz_id, card_id: card_id)
  end

  setup do
    user = user_fixture()
    quiz = quiz_fixture(user_id: user.id)
    card = card_fixture(user_id: user.id, quiz_id: quiz.id)

    # create other user for checking permissions
    other_user = user_fixture()

    %{user: user, other_user: other_user, card: card, quiz: quiz}
  end

  describe "CRUD" do
    test "lists all cards", %{conn: conn, card: card, user: user} do
      {:ok, _view, html} = conn |> login_user(user) |> live(_get_card_index_url(card.quiz_id))

      # template contains expected content
      assert html =~ "Question List"
      assert html =~ card.question
    end

    test "saves new card", %{conn: conn, user: user, quiz: quiz} do
      {:ok, view, _html} = conn |> login_user(user) |> live(_get_card_index_url(quiz.id))

      # click event on expected element renders expected content
      assert view
             |> element("a", "Create new question")
             |> render_click() =~ "New Question"

      # redirects to expected route via live patch
      assert_patch(view, _get_card_new_url(quiz.id))

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
      assert_patch(view, _get_card_index_url(quiz.id))

      # template contains expected content
      html = render(view)
      assert html =~ "Question created successfully"
      # assert html =~ "some image"
    end

    test "displays expected card", %{conn: conn, user: user, card: card} do
      {:ok, _view, html} =
        conn |> login_user(user) |> live(_get_card_show_url(card.quiz_id, card.id))

      # template contains expected content
      assert html =~ "Question Info"
      # assert html =~ card.image
    end

    test "updates expected card", %{conn: conn, user: user, card: card} do
      {:ok, view, _html} =
        conn
        |> login_user(user)
        |> live(_get_card_show_url(card.quiz_id, card.id))

      # click event on expected element renders expected content
      assert view
             |> element("a", "Edit this question")
             |> render_click() =~ "Edit Question"

      # redirects to expected route via live patch
      assert_patch(view, _get_card_edit_url(card.quiz_id, card.id))

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
      assert_patch(view, _get_card_show_url(card.quiz_id, card.id))

      # template contains expected content
      html = render(view)
      assert html =~ "Question updated successfully"
      # assert html =~ "some updated image"
    end

    test "deletes expected card", %{conn: conn, user: user, card: card} do
      success_url =
        _get_card_index_url(card.quiz_id) <> query_string(%{"delete-question-success" => "1"})

      {:ok, view, _html} =
        conn |> login_user(user) |> live(_get_card_show_url(card.quiz_id, card.id))

      # delete expected object
      view |> element("[data-test-id='delete-card']") |> render_click()

      # redirects to expected route
      view |> assert_redirected(success_url)

      # view contains expected flash message after redirect
      redirect_resp_conn = conn |> login_user(user) |> get(success_url)
      assert redirect_resp_conn.assigns.flash == %{"success" => "Question deleted successfully"}

      # template does not contain expected content after redirect
      {:ok, _view, html_after_redirect} =
        conn |> login_user(user) |> live(_get_card_index_url(card.quiz_id))

      refute html_after_redirect =~ card.question
    end
  end

  describe ":index" do
    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      assert conn |> redirects_unauthenticated_user_to_login_route(_get_card_index_url(quiz.id))
    end

    test "forbids unpermissioned user", %{conn: conn, other_user: other_user, quiz: quiz} do
      assert conn
             |> login_user(other_user)
             |> get(_get_card_new_url(quiz.id))
             |> Map.get(:status) == 403
    end
  end

  describe ":new" do
    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      assert conn |> redirects_unauthenticated_user_to_login_route(_get_card_new_url(quiz.id))
    end

    test "forbids unpermissioned user", %{conn: conn, other_user: other_user, quiz: quiz} do
      assert conn
             |> login_user(other_user)
             |> get(_get_card_new_url(quiz.id))
             |> Map.get(:status) == 403
    end
  end

  describe ":show" do
    test "redirects unauthenticated user to login route", %{conn: conn, card: card} do
      assert conn
             |> redirects_unauthenticated_user_to_login_route(
               _get_card_show_url(card.quiz_id, card.id)
             )
    end

    test "forbids unpermissioned user", %{conn: conn, other_user: other_user, card: card} do
      assert conn
             |> login_user(other_user)
             |> get(_get_card_show_url(card.quiz_id, card.id))
             |> Map.get(:status) == 403
    end
  end

  describe ":edit" do
    test "redirects unauthenticated user to login route", %{conn: conn, card: card} do
      assert conn
             |> redirects_unauthenticated_user_to_login_route(
               _get_card_show_url(card.quiz_id, card.id)
             )
    end

    test "forbids unpermissioned user", %{conn: conn, other_user: other_user, card: card} do
      assert conn
             |> login_user(other_user)
             |> get(_get_card_show_url(card.quiz_id, card.id))
             |> Map.get(:status) == 403
    end
  end
end
