defmodule QuizGameWeb.ContactUsLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  import QuizGame.TestSupport.Assertions
  import QuizGameWeb.Support.Router

  @contact_us_url route(:base, :contact_us)

  describe "ContactUsLive page" do
    test "renders expected markup", %{conn: conn} do
      {:ok, _lv, html} = live(conn, @contact_us_url)
      assert html_has_title(html, "Contact Us")
    end
  end

  describe "ContactUsLive form" do
    test "sends contact email when form data is valid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, @contact_us_url)

      # build form data
      form_data = %{
        "name" => "some name",
        "email" => "some_email@example.com",
        "message" => "some message"
      }

      # submit the form and follow the redirect
      {:ok, resp_conn} =
        form(lv, "#contact-us-form", form_data)
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      # response contains flash message
      assert conn_has_flash_message(resp_conn, :success, "Contact form submitted successfully")

      # expected email has been sent
      assert_email_sent(
        subject: "#{Application.fetch_env!(:quiz_game, :project_name)} - Contact Form Submitted"
      )
    end
  end
end
