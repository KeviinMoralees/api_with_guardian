defmodule RealDealApiWeb.Auth.SetAccount do
  import Plug.Conn
  alias RealDealApiWeb.Auth.ErrorResponse.Unauthorized
  alias RealDealApiWeb.Accounts

  def init(_options) do
  end

  def call(conn, _opts) do
    if conn.assigns[:account] do
      conn
    else
      account_id = get_session(conn, :account_id)
      if account_id = nil, do: raise(Unauthorized)
      account = Accounts.get_account!(account_id)
      cond do
        account_id && account -> assing(conn, :account, account)
        true -> assign(conn, :account, nil)
      end
    end
  end
end