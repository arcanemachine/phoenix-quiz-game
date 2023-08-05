defmodule QuizGame.UserTest do
  @moduledoc false
  use QuizGame.DataCase
  import QuizGame.Users.User

  describe "password_length_min/0" do
    test "returns expected value" do
      assert password_length_min() == 8
    end
  end
end
