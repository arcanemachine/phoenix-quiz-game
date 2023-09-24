defmodule QuizGameWeb.Support.RouterTest do
  @moduledoc false
  use ExUnit.Case
  doctest QuizGameWeb.Support.Router, only: [query_string: 1, route: 3]
end
