defmodule QuizGameWeb.ContactUsLiveTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  describe "ContactUsLive" do
    test "renders expected template", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/contact-us")

      # template contains expected title
      assert element(lv, "h1") |> render() =~ "Contact Us"
    end

    test "submits the form successfully", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/contact-us")

      test_name = "test_name"
      test_email = "test_email@example.com"
      test_message = "test_message"

      # build the form
      form_params = %{
        "contact_us" => %{
          "name" => test_name,
          "email" => test_email,
          "message" => test_message
        }
      }

      # submit the form
      {:ok, conn} =
        form(lv, "#form_contact_us", form_params)
        |> render_submit()

        # redirects to expected URL
        |> follow_redirect(conn, "/")

      # renders expected flash message
      assert Phoenix.Flash.get(conn.assigns.flash, :success) =~
               "Contact form submitted successfully"

      # expected email has been sent
      assert_email_sent(
        subject: "#{Application.fetch_env!(:quiz_game, :project_name)} - Contact Form Submitted"
      )
    end
  end
end
