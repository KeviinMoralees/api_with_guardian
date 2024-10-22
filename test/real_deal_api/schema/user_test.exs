  defmodule RealDealApi.User.UserTest do
    use ExUnit.Case
    alias RealDealApi.Users.User
    alias RealDealApi.Accounts.Account

    @expected_fields_with_types [
      {:id, :binary_id},
      {:account_id, :binary_id},
      {:full_name, :string},
      {:gender, :string},
      {:biography, :string},
      {:inserted_at, :utc_datetime },
      {:updated_at, :utc_datetime }
    ]

    describe "fields and types" do
      test "if the correct fields and types" do
        actual_fields_with_types =
        for field  <- User.__schema__(:fields) do
           type = User.__schema__(:type, field)
           {field, type}
      end
        assert  MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
      end
    end
  end
