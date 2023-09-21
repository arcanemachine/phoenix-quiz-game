defmodule QuizGame.Users.UserTest do
  @moduledoc false
  use QuizGame.DataCase
  import QuizGame.Users.User

  describe "display_name_length_max/0" do
    test "returns expected value" do
      assert display_name_length_max() == 24
    end
  end

  describe "username_length_min/0" do
    test "returns expected value" do
      assert username_length_min() == 3
    end
  end

  describe "username_length_max/0" do
    test "returns expected value" do
      assert username_length_max() == 32
    end
  end

  describe "email_length_max/0" do
    test "returns expected value" do
      assert email_length_max() == 160
    end
  end

  describe "password_length_min/0" do
    test "returns expected value" do
      assert password_length_min() == 8
    end
  end

  describe "password_length_max/0" do
    test "returns expected value" do
      assert password_length_max() == 72
    end
  end
end
