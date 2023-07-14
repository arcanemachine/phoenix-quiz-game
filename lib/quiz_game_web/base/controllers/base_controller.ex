defmodule QuizGameWeb.BaseController do
  use QuizGameWeb, :controller

  def home(conn, _params) do
    render(conn, :home, tag_title: "Home")
  end

  def privacy_policy(conn, _params) do
    render(conn, :privacy_policy, page_title: "Privacy Policy")
  end

  def terms_of_use(conn, _params) do
    render(conn, :terms_of_use, page_title: "Terms of Use")
  end
end
