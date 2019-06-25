defmodule DoorFrame.GrantType.ClientCredentialsTest do
  alias DoorFrame.Error
  alias DoorFrame.GrantType.ClientCredentials
  alias DoorFrame.Request
  alias DoorFrame.Response

  use ExUnit.Case

  setup do
    request = %Request{
      client_id: "secret_client_id",
      client_secret: "secret_client_secret",
      scope: "read write"
    }

    response = %Response{}
    [request: request, response: response]
  end

  describe "handle()" do
    test "returns an error when the request does not contain a client_id", %{response: response} do
      request = %Request{}

      assert {:error, %Error{error: "invalid_client"} = error} =
               ClientCredentials.handle(request, response)

      assert error.description =~ "client_id"
    end

    test "returns an error when the request does not contain a client_secret", %{
      response: response
    } do
      request = %Request{client_id: "secret_id"}

      assert {:error, %Error{error: "invalid_client"} = error} =
               ClientCredentials.handle(request, response)

      assert error.description =~ "client_secret"
    end

    test "calls the required callback functions of the handler", %{response: response} do
      defmodule MyHandler1 do
        use DoorFrame

        def validate_scope("read write") do
          send(self(), :validate_scope)
          {:ok, ["read", "write"]}
        end

        def get_client("secret_client_id", "secret_client_secret") do
          send(self(), :get_client_called)
          {:ok, %{id: "c"}}
        end

        def get_resource_owner(%{id: "c"}) do
          send(self(), :get_resource_owner)
          {:ok, %{id: "ro"}}
        end

        def generate_token(:access_token, _request, _response) do
          send(self(), :generate_access_token)
          {:ok, "at"}
        end

        def generate_token(:refresh_token, _request, _response) do
          send(self(), :generate_refresh_token)
          {:ok, %{id: "rt"}}
        end

        def persist_tokens(
              %{access_token: "at", refresh_token: %{id: "rt"}},
              %{client: %{id: "c"}, resource_owner: %{id: "ro"}}
            ) do
          send(self(), :persist_access_token)
          send(self(), :persist_refresh_token)
          {:ok}
        end
      end

      MyHandler1.create_request(
        client_id: "secret_client_id",
        client_secret: "secret_client_secret",
        scope: "read write"
      )
      |> ClientCredentials.handle(response)

      assert_received :validate_scope
      assert_received :get_client_called
      assert_received :get_resource_owner
      assert_received :generate_access_token
      assert_received :generate_refresh_token
      assert_received :persist_access_token
      assert_received :persist_refresh_token
    end

    test "handles errors without a description in get_client", %{
      request: request,
      response: response
    } do
      defmodule MyHandler2 do
        use DoorFrame

        def get_client(_, _) do
          {:error}
        end
      end

      assert {:error, %Error{error: "invalid_client"}} =
               MyHandler2.create_request()
               |> ClientCredentials.handle(response)
    end

    test "handles errors with a description in get_client", %{
      request: request,
      response: response
    } do
      defmodule MyHandler3 do
        use DoorFrame

        def get_client(_, _) do
          {:error, "Client not found"}
        end
      end

      assert {:error, %Error{error: "invalid_client", description: description}} =
               MyHandler3.create_request()
               |> ClientCredentials.handle(response)

      assert description = "Client not found"
    end
  end
end
