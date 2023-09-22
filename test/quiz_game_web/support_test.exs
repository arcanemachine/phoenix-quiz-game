defmodule QuizGameWeb.Support.AtomTest do
  @moduledoc false
  use ExUnit.Case
  alias QuizGameWeb.Support, as: S
  # doctest QuizGameWeb.Support.Atom

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

  @types %{some_field: :string, other_field: :string}

  describe("ensure_data_in_changes/2") do
    test "appends the data of a single field to changeset.changes" do
      data = %{some_field: "some value", other_field: "other value"}
      changes = %{}
      changeset = Ecto.Changeset.change({data, @types}, changes)

      result = S.Changeset.ensure_data_in_changes(changeset, :some_field) |> Map.get(:changes)
      assert result == %{some_field: "some value"}
    end

    test "appends the newest data of a single field to changeset.changes" do
      data = %{some_field: "some value", other_field: "other value"}
      changes = %{some_field: "new value"}
      changeset = Ecto.Changeset.change({data, @types}, changes)

      result = S.Changeset.ensure_data_in_changes(changeset, :some_field) |> Map.get(:changes)
      assert result == %{some_field: "new value"}
    end

    test "appends the data of multiple fields to changeset.changes" do
      data = %{some_field: "some value", other_field: "other value"}
      changes = %{}
      changeset = Ecto.Changeset.change({data, @types}, changes)

      result =
        S.Changeset.ensure_data_in_changes(changeset, [:some_field, :other_field])
        |> Map.get(:changes)

      assert result == %{some_field: "some value", other_field: "other value"}
    end
  end

  describe("get_value_from_changes_or_data/2") do
    test "returns initial value if changeset does not have changed value" do
      data = %{some_field: "some value"}
      changes = %{}
      changeset = Ecto.Changeset.change({data, @types}, changes)

      result = S.Changeset.get_value_from_changes_or_data(changeset, :some_field)
      assert result == "some value"
    end

    test "returns changed value if changeset has changed value" do
      # create changeset
      data = %{some_field: "some value"}
      changes = %{some_field: "new value"}
      changeset = Ecto.Changeset.change({data, @types}, changes)

      # sanity check: changeset does not initially contain final value
      refute changeset.data[:some_field] == "new value"

      result = S.Changeset.get_value_from_changes_or_data(changeset, :some_field)
      assert result == "new value"
    end
  end

  describe("get_values_from_changes_or_data/2") do
    test "returns expected list of values" do
      # create changeset (empty value for field)
      data = %{some_field: "some value", other_field: "other value"}
      changes = %{other_field: "new value"}
      changeset = Ecto.Changeset.change({data, @types}, changes)

      result =
        S.Changeset.get_values_from_changes_or_data(changeset, [:some_field, :other_field])

      assert result == ["some value", "new value"]
    end
  end

  describe("validate_changed/3") do
    test "returns unchanged changeset if field value has changed" do
      # create changeset (empty value for field)
      data = %{some_field: "some value"}
      changes = %{some_field: "new value"}
      changeset = Ecto.Changeset.change({data, @types}, changes)

      result = S.Changeset.validate_changed(changeset, :some_field)
      assert result == changeset
    end

    test "adds error if field value has not changed" do
      # create changeset (empty value for field)
      data = %{some_field: "some value"}
      changes = %{}
      changeset = Ecto.Changeset.change({data, @types}, changes)

      result = S.Changeset.validate_changed(changeset, :some_field)
      assert result != changeset
      assert result.errors == [some_field: {"should be different than the original value", []}]
    end

    test "adds error if field value has not changed (with custom message)" do
      # create changeset (empty value for field)
      data = %{some_field: "some value"}
      changes = %{}
      changeset = Ecto.Changeset.change({data, @types}, changes)

      result = S.Changeset.validate_changed(changeset, :some_field, message: "should be changed")
      assert result != changeset
      assert result.errors == [some_field: {"should be changed", []}]
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
    test "raises expected assertion if range is 0..0" do
      assert_raise(ArgumentError, "range cannot be 0..0", fn ->
        S.Range.get_non_zero_value(0..0)
      end)
    end

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
