defmodule RealDealApi.Schema.AccountTest do
  use ExUnit.Case
  alias Ecto.Changeset
  alias RealDealApi.Accounts.Account

  @expected_fields_with_types [
    {:id, :binary_id},
    {:email, :string},
    {:hash_password, :string},
    {:inserted_at, :utc_datetime},
    {:updated_at, :utc_datetime}
  ]

  @optional [:id, :inserted_at, :updated_at]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Account.__schema__(:fields) do
          type = Account.__schema__(:type, field)
          {field, type}
        end

      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = %{
        "id" => Ecto.UUID.generate(),
        "email" => "test@email.com",
        "hash_password" => "test password",
        "inserted_at" => DateTime.utc_now(),
        "updated_at" => DateTime.utc_now()
      }

      changeset = Account.changeset(%Account{}, valid_params)

      assert %Ecto.Changeset{valid?: true, changes: changes} = changeset

      mutated = [:hash_password]

      for {field, _} <- @expected_fields_with_types, field not in mutated do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]
      # Ensure both values are DateTime truncated to seconds for comparison
        if field in [:inserted_at, :updated_at] do
          actual = DateTime.truncate(actual, :second)
          expected = DateTime.truncate(expected, :second)
          assert actual == expected,
               "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
        end

      end

      assert Bcrypt.verify_pass(valid_params["hash_password"], changes.hash_password),
             "Password: #{inspect(valid_params["hash_password"])} does not match \nhash: #{inspect(changes.hash_password)}"
    end

    test "error: returns an error changeset when given un-castable values" do
      invalid_params = %{
        "id" => NaiveDateTime.local_now(),
        "email" => NaiveDateTime.local_now(),
        "hash_password" => NaiveDateTime.local_now(),
        "inserted_at" => "lets put a string here",
        "updated_at" => "updated to a string"
      }

      assert %Changeset{valid?: false, errors: errors} =
               Account.changeset(%Account{}, invalid_params)

      for {field, _} <- @expected_fields_with_types do
        assert errors[field], "The field: #{field} is missing from errors."

        {_, meta} = errors[field]

        assert meta[:validation] == :cast,
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} = Account.changeset(%Account{}, params)

      for {field, _} <- @expected_fields_with_types, field not in @optional do
        assert errors[field], "The field: #{field} is missing from errors."

        {_, meta} = errors[field]

        assert meta[:validation] == :required,
               "The validation type, #{meta[:validation]}, is incorrect."
      end

      for field <- @optional do
        refute errors[field], "The optional field #{field} is required when it shouldn't be."
      end
    end

    # test "error: returns error changeset when an email address is reused" do
    #   Ecto.Adapters.SQL.Sandbox.checkout(RealDealApi.Repo)

    #   {:ok, existing_account} =
    #     %Account{}
    #     |> Account.changeset(valid_params(@expected_fields_with_types))
    #     |> RealDealApi.Repo.insert()

    #   changeset_with_repeated_email =
    #     %Account{}
    #     |> Account.changeset(
    #       valid_params(@expected_fields_with_types)
    #       |> Map.put("email", existing_account.email)
    #     )

    #   assert {:error, %Changeset{valid?: false, errors: errors}} =
    #            RealDealApi.Repo.insert(changeset_with_repeated_email)

    #   assert errors[:email], "The field :email is missing from errors."

    #   {_, meta} = errors[:email]

    #   assert meta[:constraint] == :unique,
    #          "The validation type, #{meta[:validation]}, is incorrect"
    # end
  end
end
