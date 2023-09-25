defmodule QuizGameWeb.Quizzes.Card.LiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.{Assertions, GenericTests}
  import QuizGame.TestSupport.Fixtures.{Quizzes, Users}

  alias QuizGame.Quizzes.Card
  alias QuizGameWeb.Support, as: S

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

  setup do
    user = user_fixture()
    quiz = quiz_fixture(user_id: user.id)
    card = card_fixture(user_id: user.id, quiz_id: quiz.id)

    # create other user for checking permissions
    other_user = user_fixture()

    %{user: user, other_user: other_user, quiz: quiz, card: card}
  end

  describe "CRUD" do
    test "lists all cards", %{conn: conn, card: card, user: user} do
      {:ok, _view, html} = conn |> login_user(user) |> live(~p"/quizzes/#{card.quiz_id}/cards")

      # template contains expected content
      assert html =~ "Question List"
      assert html =~ card.question
    end

    test "saves new card", %{conn: conn, user: user, quiz: quiz} do
      {:ok, view, _html} = conn |> login_user(user) |> live(~p"/quizzes/#{quiz.id}/cards")

      # click event on expected element renders expected content
      assert view
             |> element("a", "Create new question")
             |> render_click() =~ "New Question"

      # redirects to expected route via live patch
      assert_patch(view, ~p"/quizzes/#{quiz.id}/cards/create")

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
      assert_patch(view, ~p"/quizzes/#{quiz.id}/cards")

      # template contains expected content
      html = render(view)
      assert html =~ "Question created successfully"
      # assert html =~ "some image"
    end

    test "displays expected card", %{conn: conn, user: user, card: card} do
      {:ok, _view, html} =
        conn |> login_user(user) |> live(~p"/quizzes/#{card.quiz_id}/cards/#{card.id}")

      # template contains expected content
      assert html =~ "Question Info"
      # assert html =~ card.image
    end

    test "updates expected card", %{conn: conn, user: user, card: card} do
      {:ok, view, _html} =
        conn
        |> login_user(user)
        |> live(~p"/quizzes/#{card.quiz_id}/cards/#{card.id}")

      # click event on expected element renders expected content
      assert view
             |> element("a", "Edit this question")
             |> render_click() =~ "Edit Question"

      # redirects to expected route via live patch
      assert_patch(view, ~p"/quizzes/#{card.quiz_id}/cards/#{card.id}/update")

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
      assert_patch(view, ~p"/quizzes/#{card.quiz_id}/cards/#{card.id}")

      # template contains expected content
      html = render(view)
      assert html =~ "Question updated successfully"
      # assert html =~ "some updated image"
    end

    test "deletes expected card", %{conn: conn, user: user, card: card} do
      success_url = ~p"/quizzes/#{card.quiz_id}/cards?delete-question-success=1"

      {:ok, view, _html} =
        conn |> login_user(user) |> live(~p"/quizzes/#{card.quiz_id}/cards/#{card.id}")

      # delete expected object
      view |> element("[data-test-id='delete-card']") |> render_click()

      # redirects to expected route
      view |> assert_redirected(success_url)

      # view contains expected flash message after redirect
      redirect_resp_conn = conn |> login_user(user) |> get(success_url)
      assert redirect_resp_conn.assigns.flash == %{"success" => "Question deleted successfully"}

      # template does not contain expected content after redirect
      {:ok, _view, html_after_redirect} =
        conn |> login_user(user) |> live(~p"/quizzes/#{card.quiz_id}/cards")

      refute html_after_redirect =~ card.question
    end
  end

  describe ":index" do
    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      assert conn |> redirects_unauthenticated_user_to_login_route(~p"/quizzes/#{quiz.id}/cards")
    end

    test "forbids unpermissioned user", %{conn: conn, other_user: other_user, quiz: quiz} do
      assert conn
             |> login_user(other_user)
             |> get(~p"/quizzes/#{quiz.id}/cards/create")
             |> Map.get(:status) == 403
    end
  end

  describe ":new" do
    test "redirects unauthenticated user to login route", %{conn: conn, quiz: quiz} do
      assert conn
             |> redirects_unauthenticated_user_to_login_route(
               ~p"/quizzes/#{quiz.id}/cards/create"
             )
    end

    test "forbids unpermissioned user", %{conn: conn, other_user: other_user, quiz: quiz} do
      assert conn
             |> login_user(other_user)
             |> get(~p"/quizzes/#{quiz.id}/cards/create")
             |> Map.get(:status) == 403
    end
  end

  describe ":show" do
    test "redirects unauthenticated user to login route", %{conn: conn, card: card} do
      assert conn
             |> redirects_unauthenticated_user_to_login_route(
               ~p"/quizzes/#{card.quiz_id}/cards/#{card.id}"
             )
    end

    test "forbids unpermissioned user", %{conn: conn, other_user: other_user, card: card} do
      assert conn
             |> login_user(other_user)
             |> get(~p"/quizzes/#{card.quiz_id}/cards/#{card.id}")
             |> Map.get(:status) == 403
    end
  end

  describe ":edit" do
    test "redirects unauthenticated user to login route", %{conn: conn, card: card} do
      assert conn
             |> redirects_unauthenticated_user_to_login_route(
               ~p"/quizzes/#{card.quiz_id}/cards/#{card.id}"
             )
    end

    test "forbids unpermissioned user", %{conn: conn, other_user: other_user, card: card} do
      assert conn
             |> login_user(other_user)
             |> get(~p"/quizzes/#{card.quiz_id}/cards/#{card.id}")
             |> Map.get(:status) == 403
    end
  end

  describe "form component" do
    test "if :format is blank, then the form only displays the :question and :format fields ", %{
      conn: conn,
      user: user,
      quiz: quiz
    } do
      {:ok, _view, html} = conn |> login_user(user) |> live(~p"/quizzes/#{quiz.id}/cards/create")

      # form should display expected result by default, so we can make our assertions immediately
      # after the HTML has rendered

      # markup contains default fields (:question and :format)
      assert html_has_element(html, ~s|input[name="card[question]"]|)
      assert html_has_element(html, ~s|select[name="card[format]"]|)

      # markup does not contain any other fields
      assert html |> Floki.find("div[phx-feedback-for]") |> length() == 2
    end

    test "shows :correct_answer field if :format is not blank", %{
      conn: conn,
      user: user,
      quiz: quiz
    } do
      {:ok, view, html} = conn |> login_user(user) |> live(~p"/quizzes/#{quiz.id}/cards/create")

      # sanity check: expected field(s) are not visible
      refute html_has_element(html, ~s|input[name="card[correct_answer]"]|)

      # randomly select a valid :format option
      format_value = Enum.random(S.Ecto.get_enum_field_options(Card, :format))

      # assign a non-blank value for :format
      changed_html =
        view |> form("#card-form", card: %{"format" => format_value}) |> render_change()

      # expected field(s) are now visible (check for element type based on the value of the
      # randomly-generated format)
      cond do
        format_value in [:multiple_choice, :true_or_false] ->
          assert(html_has_element(changed_html, ~s|select[name="card[correct_answer]"]|))

        format_value in [:number_entry, :text_entry] ->
          assert(html_has_element(changed_html, ~s|input[name="card[correct_answer]"]|))
      end
    end

    test "if :format is :multiple_choice, then :choice_X fields are visible", %{
      conn: conn,
      user: user,
      quiz: quiz
    } do
      {:ok, view, html} = conn |> login_user(user) |> live(~p"/quizzes/#{quiz.id}/cards/create")

      # sanity check: expected field(s) are not visible
      refute html_has_element(html, ~s|input[name="card[choice_1]"]|)
      refute html_has_element(html, ~s|input[name="card[choice_2]"]|)
      refute html_has_element(html, ~s|input[name="card[choice_3]"]|)
      refute html_has_element(html, ~s|input[name="card[choice_4]"]|)
      refute html_has_element(html, ~s|select[name="card[correct_answer]"]|)

      # assign expected value for :format
      changed_html =
        view |> form("#card-form", card: %{"format" => "multiple_choice"}) |> render_change()

      # expected field(s) are now visible
      assert html_has_element(changed_html, ~s|input[name="card[choice_1]"]|)
      assert html_has_element(changed_html, ~s|input[name="card[choice_2]"]|)
      assert html_has_element(changed_html, ~s|input[name="card[choice_3]"]|)
      assert html_has_element(changed_html, ~s|input[name="card[choice_4]"]|)
      assert html_has_element(changed_html, ~s|select[name="card[correct_answer]"]|)
    end

    test "if :format is :multiple_choice, then :correct_answer field type is 'text'", %{
      conn: conn,
      user: user,
      quiz: quiz
    } do
      {:ok, view, html} = conn |> login_user(user) |> live(~p"/quizzes/#{quiz.id}/cards/create")

      # sanity check: expected field(s) are not visible
      refute html_has_element(html, ~s|select[name="card[correct_answer]"]|)

      # assign expected value for :format
      changed_html =
        view |> form("#card-form", card: %{"format" => "number_entry"}) |> render_change()

      # expected field(s) are now visible
      assert html_has_element(changed_html, ~s|input[type="number"][name="card[correct_answer]"]|)
    end

    test "if :format is :number_entry, then :correct_answer field type is 'number'", %{
      conn: conn,
      user: user,
      quiz: quiz
    } do
      {:ok, view, html} = conn |> login_user(user) |> live(~p"/quizzes/#{quiz.id}/cards/create")

      # sanity check: expected field(s) are not visible
      refute html_has_element(html, ~s|select[name="card[correct_answer]"]|)

      # assign expected value for :format
      changed_html =
        view |> form("#card-form", card: %{"format" => "text_entry"}) |> render_change()

      # expected field(s) are now visible
      assert html_has_element(changed_html, ~s|input[type="text"][name="card[correct_answer]"]|)
    end

    test "if :format is :true_or_false, then :correct_answer field type is 'select'", %{
      conn: conn,
      user: user,
      quiz: quiz
    } do
      {:ok, view, html} = conn |> login_user(user) |> live(~p"/quizzes/#{quiz.id}/cards/create")

      # sanity check: expected field(s) are not visible
      refute html_has_element(html, ~s|select[name="card[correct_answer]"]|)

      # assign expected value for :format
      changed_html =
        view |> form("#card-form", card: %{"format" => "true_or_false"}) |> render_change()

      # expected field(s) are now visible
      assert html_has_element(changed_html, ~s|select[name="card[correct_answer]"]|)
    end

    test "if :format is :text_entry, then :correct_answer field type is 'text'", %{
      conn: conn,
      user: user,
      quiz: quiz
    } do
      {:ok, view, html} = conn |> login_user(user) |> live(~p"/quizzes/#{quiz.id}/cards/create")

      # sanity check: expected field(s) are not visible
      refute html_has_element(html, ~s|select[name="card[correct_answer]"]|)

      # assign expected value for :format
      changed_html =
        view |> form("#card-form", card: %{"format" => "text_entry"}) |> render_change()

      # expected field(s) are now visible
      assert html_has_element(changed_html, ~s|input[type="text"][name="card[correct_answer]"]|)
    end
  end
end
