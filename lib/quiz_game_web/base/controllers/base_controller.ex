defmodule QuizGameWeb.BaseController do
  use QuizGameWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
