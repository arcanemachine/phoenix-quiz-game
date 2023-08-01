defmodule QuizGameWeb.ConnTest do
  @moduledoc false

  use QuizGameWeb.ConnCase

  alias QuizGameWeb.Conn, as: ProjectConn

  describe("text_response/3") do
    test "when is_atom(status)", %{conn: conn} do
      response = ProjectConn.text_response(conn, :ok)

      # returns expected response
      assert text_response(response, :ok) =~ "ok"
    end

    test "when is_atom(status) and custom response body", %{conn: conn} do
      response = ProjectConn.text_response(conn, :ok, "OK")

      # returns expected response
      assert text_response(response, :ok) =~ "OK"
    end

    test "when is_integer(status)", %{conn: conn} do
      response = ProjectConn.text_response(conn, 200)

      # returns expected response
      assert text_response(response, 200) =~ "200"
    end

    test "when is_integer(status) and custom response body", %{conn: conn} do
      response = ProjectConn.text_response(conn, 200, "OK")

      # returns expected response
      assert text_response(response, 200) =~ "OK"
    end
  end
end
