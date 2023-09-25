defmodule QuizGameWeb.Core.Controller do
  @moduledoc false
  use QuizGameWeb, :controller

  def root(conn, _params) do
    render(conn, :root, page_title: "Quiz Game", tag_title: "Home")
  end

  def privacy_policy(conn, _params) do
    render(conn, :privacy_policy, page_title: "Privacy Policy")
  end

  def terms_of_use(conn, _params) do
    render(conn, :terms_of_use, page_title: "Terms of Use")
  end
end
