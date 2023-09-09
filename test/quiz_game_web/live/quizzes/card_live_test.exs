defmodule QuizGameWeb.Quizzes.CardLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import QuizGame.TestSupport.QuizzesFixtures
  import QuizGame.TestSupport.UsersFixtures

  @create_attrs %{
    format: :multiple_choice,
    image: "some image",
    question: "some question",
    answers: ["option1", "option2"]
  }
  @update_attrs %{
    format: :true_or_false,
    image: "some updated image",
    question: "some updated question",
    answers: ["option1"]
  }
  @invalid_attrs %{format: nil, image: nil, question: nil, answers: []}

  setup do
    user = user_fixture()
    quiz = quiz_fixture()
    card = card_fixture(user_id: user.id, quiz_id: quiz.id)
    %{card: card}
  end

  describe "Index" do
    # setup [:create_card]

    test "lists all cards", %{conn: conn, card: card} do
      {:ok, _index_live, html} = live(conn, ~p"/quizzes/cards")

      assert html =~ "Listing Questions"
      assert html =~ card.image
    end

    test "saves new card", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/quizzes/cards")

      assert index_live |> element("a", "New Question") |> render_click() =~
               "New Question"

      assert_patch(index_live, ~p"/quizzes/cards/new")

      assert index_live
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#card-form", card: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/quizzes/cards")
      # assert_patch(index_live, route(:quizzes_cards, :index, quiz_id: quiz.id))

      html = render(index_live)
      assert html =~ "Question created successfully"
      assert html =~ "some image"
    end

    test "updates card in listing", %{conn: conn, card: card} do
      {:ok, index_live, _html} = live(conn, ~p"/quizzes/cards")

      assert index_live |> element("#cards-#{card.id} a", "Edit") |> render_click() =~
               "Edit Question"

      assert_patch(index_live, ~p"/quizzes/cards/#{card}/edit")

      assert index_live
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#card-form", card: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/quizzes/cards")

      html = render(index_live)
      assert html =~ "Question updated successfully"
      assert html =~ "some updated image"
    end

    test "deletes card in listing", %{conn: conn, card: card} do
      {:ok, index_live, _html} = live(conn, ~p"/quizzes/cards")

      assert index_live |> element("#cards-#{card.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cards-#{card.id}")
    end
  end

  describe "Show" do
    # setup [:create_card]

    test "displays card", %{conn: conn, card: card} do
      {:ok, _show_live, html} = live(conn, ~p"/quizzes/cards/#{card}")

      assert html =~ "Question Info"
      # assert html =~ card.image
    end

    test "updates card within modal", %{conn: conn, card: card} do
      {:ok, show_live, _html} = live(conn, ~p"/quizzes/cards/#{card}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Question"

      assert_patch(show_live, ~p"/quizzes/cards/#{card}/show/edit")

      assert show_live
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#card-form", card: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/quizzes/cards/#{card}")

      html = render(show_live)
      assert html =~ "Card updated successfully"
      assert html =~ "some updated image"
    end
  end
end
