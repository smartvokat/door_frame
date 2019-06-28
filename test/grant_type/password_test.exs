defmodule DoorFrame.GrantType.PasswordTest do
  alias DoorFrame.Error
  alias DoorFrame.GrantType.Password
  alias DoorFrame.Request
  alias DoorFrame.Response

  use ExUnit.Case

  setup do
    request = %Request{
      client_id: "secret_client_id",
      client_secret: "secret_client_secret",
      username: "jane.doe@example.com",
      password: "secret_password",
      scope: "read write"
    }

    response = %Response{}
    [request: request, response: response]
  end

  describe "handle()" do
    test "fails on missing client_id", %{response: response} do
      request = %Request{}

      assert {:error, %Error{error: "invalid_request"} = error} =
               Password.handle(request, response)

      assert error.description =~ "client_id"
    end

    test "fails on missing client_secret", %{
      response: response
    } do
      request = %Request{client_id: "secret_id"}

      assert {:error, %Error{error: "invalid_request"} = error} =
               Password.handle(request, response)

      assert error.description =~ "client_secret"
    end

    test "fails on missing username", %{
      response: response
    } do
      request = %Request{client_id: "id", client_secret: "id"}

      assert {:error, %Error{error: "invalid_request"} = error} =
               Password.handle(request, response)

      assert error.description =~ "username"
    end

    test "fails on missing password", %{
      response: response
    } do
      request = %Request{client_id: "id", client_secret: "id", username: "test"}

      assert {:error, %Error{error: "invalid_request"} = error} =
               Password.handle(request, response)

      assert error.description =~ "password"
    end

    test "calls the required callback functions of the handler", %{response: response} do
      defmodule MyHandler1 do
        use DoorFrame

        def validate_scope("read write") do
          send(self(), :validate_scope)
          {:ok, ["read", "write"]}
        end

        def get_client(%Request{} = request, %Response{}) do
          assert request.client_id == "secret_client_id"
          assert request.client_secret == "secret_client_secret"
          send(self(), :get_client_called)
          {:ok, %{id: "c"}}
        end

        def get_resource_owner(%Request{}, %Response{client: %{id: "c"}}) do
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
        username: "test",
        password: "test",
        scope: "read write"
      )
      |> Password.handle(response)

      assert_received :validate_scope
      assert_received :get_client_called
      assert_received :get_resource_owner
      assert_received :generate_access_token
      assert_received :generate_refresh_token
      assert_received :persist_access_token
      assert_received :persist_refresh_token
    end
  end
end
