defmodule DoorFrameTest do
  alias DoorFrame.Error

  use ExUnit.Case

  describe "token()" do
    test "fails if there is no grant_type" do
      context = DoorFrame.create_context()
      request = DoorFrame.create_request()
      assert {:error, %Error{error: error}} = DoorFrame.token(context, request)
      assert error = "invalid_grant"
    end

    test "fails if there is no available handler for this grant_type" do
      context = DoorFrame.create_context(available_grant_types: %{})
      request = DoorFrame.create_request(grant_type: "client_credentials")
      assert {:error, %Error{error: error}} = DoorFrame.token(context, request)
      assert error = "server_error"
    end

    test "supports the client_credential grant type" do
      defmodule MyHandler1 do
        use DoorFrame.Handler

        def get_client(_, _) do
          {:ok, %{id: "a_client"}}
        end

        def get_resource_owner(_) do
          {:ok, %{id: "a_resource_owner"}}
        end

        def persist_tokens(_tokens, _, _) do
          {:ok}
        end
      end

      context = DoorFrame.create_context(handler: MyHandler1)

      request =
        DoorFrame.create_request(
          grant_type: "client_credentials",
          client_id: "a_client",
          client_secret: "secret"
        )

      assert {:ok, response} = DoorFrame.token(context, request)
    end
  end
end
