  defmodule RealDealApi.Schema.AccountTest do
    
    use ExUnit.Case

    alias Ecto.Changeset
    alias RealDealApi.Accounts.Account


    @expected_fields_with_types [
      {:id, :binary_id},
      {:email, :string},
      {:hash_password, :string},
      {:inserted_at, :utc_datetime },
      {:updated_at, :utc_datetime }
    ]

    describe "fields and types" do
      test "if hasa the correct fields and types" do 
        actual_fields_with_types = 
            for field <- Account.__schema__(:fields) do
        type = Account.__schema__(:type, field)
        {field, type}
      end
        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
      end
    end

      describe "changeset/2" do 
          test "success:  return a valid changeset when given valid arguments" do
            valid_params = %{
              "id" => Ecto.UUID.generate(),
              "email" => "test@mail.com",
              "hash_password" => "test password",
              "inserted_at" => NaiveDateTime.local_now(),
              "updated_at" => NaiveDateTime.local_now()

            }
            changeset = Account.changeset(%Account{}, valid_params)
            

            assert %Changeset{valid?: true, changes: changes} = changeset

            mutated = [:hash_password]


              for {field, _} <- @expected_fields_with_types, field not in mutated do
                actual = Map.get(changes, field)
                expected = valid_params[Atom.to_string(field)]
                assert actual == expected , "Values did not match for field: #{field}\nactual: #{inspect(actual)}"
              end

            assert Bcrypt.verify_pass(valid_params["hash_password"], changes.hash_password), "password: #{inspect(valid_params["hash_password"])} does not match \nhash: #{inspect("changes.hash_password")}"

            end
      end
  end
