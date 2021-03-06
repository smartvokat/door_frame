defmodule DoorFrame.Adapter.PlugTest do
  alias DoorFrame.Adapter.Plug, as: Adapter
  alias DoorFrame.Error
  alias DoorFrame.Response
  alias Plug

  use ExUnit.Case
  use Plug.Test

  def create_plug_conn(method, %{client_id: client_id, client_secret: client_secret}, body_params) do
    credentials = Base.encode64(client_id <> ":" <> client_secret)

    conn(method, "/", body_params)
    |> Plug.Conn.put_req_header("authorization", "Basic #{credentials}")
  end

  defmodule MyHandler2 do
    use DoorFrame
  end

  setup do
    request = MyHandler2.create_request()
    response = %Response{}
    [request: request, response: response]
  end

  describe "to_request()" do
    test "extracts client credentials from a basic authorization header correctly", %{
      request: request
    } do
      conn =
        create_plug_conn(
          :post,
          %{client_id: "a_client_id", client_secret: "a_client_secret"},
          %{}
        )

      assert {:ok, request} = Adapter.to_request(request, conn)
      assert request.client_id == "a_client_id"
      assert request.client_secret == "a_client_secret"
    end

    test "extracts grant_type, username, password and scope from the request body", %{
      request: request
    } do
      conn =
        create_plug_conn(:post, %{client_id: "id", client_secret: "secret"}, %{
          username: "john.doe@example.com",
          password: "test",
          scope: "read write",
          grant_type: "password"
        })

      assert {:ok, request} = Adapter.to_request(request, conn)
      assert request.grant_type == "password"
      assert request.username == "john.doe@example.com"
      assert request.password == "test"
      assert request.scope == "read write"
    end

    test "fails when there is no valid basic authorization header", %{request: request} do
      conn = conn(:pst, "/", %{})
      assert {:error, %Error{error: error, description: desc}} = Adapter.to_request(request, conn)
      assert error = "invalid_request"
      assert desc = "Missing authorization header"
    end

    test "fails when there is a malformed basic authorization header", %{request: request} do
      conn =
        conn(:pst, "/", %{})
        |> Plug.Conn.put_req_header("authorization", "Basic #{Base.encode64("foo/bar")}")

      assert {:error, %Error{error: error, description: desc}} = Adapter.to_request(request, conn)
      assert error = "invalid_request"
      assert desc = "Missing authorization header"
    end
  end

  describe "to_response()" do
    test "exports a minimal response to JSON" do
      response = %Response{access_token: "a_token"}
      conn = Adapter.to_response(response, conn(:pst, "/", %{}))

      assert conn.status == 200
      assert conn.resp_body == Jason.encode!(%{access_token: "a_token", token_type: "bearer"})
    end

    test "exports a minimal error to JSON" do
      error = Error.invalid_grant()
      conn = Adapter.to_response(error, conn(:pst, "/", %{}))

      assert conn.status == error.status_code
      assert conn.resp_body == Jason.encode!(%{error: "invalid_grant"})
    end

    test "adds expires_in correctly" do
      response = %Response{access_token: "a_token", expires_in: 60 * 60 * 24}
      conn = Adapter.to_response(response, conn(:pst, "/", %{}))

      assert conn.status == 200

      assert conn.resp_body ==
               Jason.encode!(%{access_token: "a_token", token_type: "bearer", expires_in: 86400})
    end

    test "adds refresh_token correctly" do
      response = %Response{
        access_token: "a_token",
        refresh_token: "a_refresh_token"
      }

      conn = Adapter.to_response(response, conn(:pst, "/", %{}))

      assert conn.status == 200

      assert conn.resp_body ==
               Jason.encode!(%{
                 access_token: "a_token",
                 token_type: "bearer",
                 refresh_token: "a_refresh_token"
               })
    end
  end
end
