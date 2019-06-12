defmodule DoorFrame.Adapter.PlugTest do
  alias DoorFrame.Adapter.Plug, as: Adapter
  alias Plug

  use ExUnit.Case
  use Plug.Test

  def create_plug_conn(method, %{client_id: client_id, client_secret: client_secret}, body_params) do
    credentials = Base.encode64(client_id <> ":" <> client_secret)

    conn(method, "/", body_params)
    |> Plug.Conn.put_req_header("authorization", "Basic #{credentials}")
  end

  describe "to_request()" do
    test "extracts client credentials from a basic authorization header correctly" do
      conn =
        create_plug_conn(
          :post,
          %{client_id: "a_client_id", client_secret: "a_client_secret"},
          %{}
        )

      assert {:ok, request} = Adapter.to_request(conn)
      assert request.client_id == "a_client_id"
      assert request.client_secret == "a_client_secret"
    end

    test "extracts the grant_type from the request body" do
      conn =
        create_plug_conn(:post, %{client_id: "a_client_id", client_secret: "a_client_secret"}, %{
          grant_type: "client_credentials"
        })

      assert {:ok, request} = Adapter.to_request(conn)
      assert request.grant_type == "client_credentials"
    end
  end
end
