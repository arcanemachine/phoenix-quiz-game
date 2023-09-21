defmodule QuizGame.Quizzes.QuizTest do
  @moduledoc false
  use QuizGame.DataCase
  import QuizGame.Quizzes.Quiz

  describe "math_random_question_count_min/0" do
    test "returns expected value" do
      assert math_random_question_count_min() == 0
    end
  end

  describe "math_random_question_count_max/0" do
    test "returns expected value" do
      assert math_random_question_count_max() == 500
    end
  end

  describe "math_random_question_value_min/0" do
    test "returns expected value" do
      assert math_random_question_value_min() == -999
    end
  end

  describe "math_random_question_value_max/0" do
    test "returns expected value" do
      assert math_random_question_value_max() == 999
    end
  end
end
