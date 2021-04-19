defmodule DoorFrameTest do
  alias DoorFrame.Error

  use ExUnit.Case

  defmodule MyHandler do
    use DoorFrame
  end

  describe "token()" do
    test "fails if there is no grant_type" do
      request = MyHandler.create_request()
      assert {:error, %Error{error: error}} = MyHandler.token(request)
      assert error = "invalid_grant"
    end

    test "fails if there is no available handler for this grant_type" do
      request =
        MyHandler.create_request(available_grant_types: %{}, grant_type: "client_credentials")

      assert {:error, %Error{error: error}} = MyHandler.token(request)
      assert error = "server_error"
    end

    test "supports the client_credential grant type" do
      defmodule MyHandler1 do
        use DoorFrame

        def get_client(_, _) do
          {:ok, %{id: "a_client"}}
        end

        def get_resource_owner(_) do
          {:ok, %{id: "a_resource_owner"}}
        end

        def persist_tokens(_tokens, _response) do
          :ok
        end
      end

      request =
        MyHandler1.create_request(
          grant_type: "client_credentials",
          client_id: "a_client",
          client_secret: "secret"
        )

      assert {:ok, response} = MyHandler1.token(request)
    end
  end
end
