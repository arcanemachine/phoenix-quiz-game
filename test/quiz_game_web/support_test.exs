defmodule QuizGameWeb.Support.AtomTest do
  @moduledoc false
  # doctest QuizGameWeb.Support.Atom
  use ExUnit.Case
  alias QuizGameWeb.Support, as: S

  # Conn
  describe("to_human_friendly_string/1") do
    test "converts atom to human-friendly string" do
      result = S.Atom.to_human_friendly_string(:some_value)
      assert result == "Some value"
    end
  end
end

defmodule QuizGameWeb.Support.ChangesetTest do
  @moduledoc false
  use ExUnit.Case
  alias QuizGameWeb.Support, as: S

  describe("get_changed_or_existing_value/2") do
    test "returns changed value if changeset has changed value" do
      # create changeset
      types = %{some_field: :string}
      data = %{some_field: "some value"}
      changes = %{some_field: "new value"}
      changeset = Ecto.Changeset.change({data, types}, changes)

      # sanity check: changeset does not initially contain final value
      refute changeset.data[:some_field] == "new value"

      result = S.Changeset.get_changed_or_existing_value(changeset, :some_field)
      assert result == "new value"
    end

    test "returns initial value if changeset does not have changed value" do
      # create changeset (empty value for field)
      types = %{some_field: :string}
      data = %{some_field: "some value"}
      changes = %{}
      changeset = Ecto.Changeset.change({data, types}, changes)

      result = S.Changeset.get_changed_or_existing_value(changeset, :some_field)
      assert result == "some value"
    end
  end
end

defmodule QuizGameWeb.Support.ConnTest do
  @moduledoc false
  use QuizGameWeb.ConnCase
  alias QuizGameWeb.Support, as: S

  describe("text_response/3") do
    test "when is_integer(status)", %{conn: conn} do
      response = S.Conn.text_response(conn, 200)
      assert text_response(response, 200) =~ "OK"
    end

    test "when is_integer(status) and custom response body", %{conn: conn} do
      response = S.Conn.text_response(conn, 200, "Some resp_body")
      assert text_response(response, 200) =~ "Some resp_body"
    end
  end
end

defmodule QuizGameWeb.Support.EctoTest do
  @moduledoc false

  use Ecto.Schema
  use ExUnit.Case

  alias QuizGameWeb.Support, as: S

  schema "some_schema" do
    field :some_enum_field, Ecto.Enum, values: [:first_option, :second_option]
  end

  describe("get_enum_field_options/2") do
    test "returns expected enum field options" do
      result = S.Ecto.get_enum_field_options(__MODULE__, :some_enum_field)
      assert result == [:first_option, :second_option]
    end
  end
end

defmodule QuizGameWeb.Support.MathTest do
  @moduledoc false
  use ExUnit.Case
  alias QuizGameWeb.Support, as: S

  describe("generate_divisible_pair/1") do
    test "generates divisible pairs with no remainder (with dynamic first value)" do
      for _ <- 1..100 do
        {first_value, second_value} = S.Math.generate_divisible_pair(-100, 100)
        assert rem(first_value, second_value) == 0
      end
    end

    test "generates divisible pairs with no remainder (with static first value)" do
      for _ <- 1..100 do
        static_first_value = 10

        {first_value, second_value} =
          S.Math.generate_divisible_pair(-100, 100, static_first_value)

        assert first_value == static_first_value
        assert rem(first_value, second_value) == 0
      end
    end
  end
end

defmodule QuizGameWeb.Support.MapTest do
  @moduledoc false
  use ExUnit.Case
  doctest QuizGameWeb.Support.Map
end

defmodule QuizGameWeb.Support.RangeTest do
  @moduledoc false
  use ExUnit.Case
  alias QuizGameWeb.Support, as: S

  describe("get_non_zero_value/1") do
    test "returns a non-zero value from a range" do
      for _ <- 1..100 do
        result = S.Range.get_non_zero_value(-100..100)
        refute result == 0
      end
    end
  end
end

defmodule QuizGameWeb.Support.StringTest do
  @moduledoc false
  use ExUnit.Case
  doctest QuizGameWeb.Support.String
end
