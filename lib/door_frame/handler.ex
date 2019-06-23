defmodule DoorFrame.Handler do
  @moduledoc false

  @callback validate_scope(any()) :: {:ok, any()} | {:error, atom}
  @callback generate_access_token(any(), any()) :: {:ok, any()} | {:error, atom}
  @callback generate_refresh_token(any(), any()) :: {:ok, any()} | {:error, atom}

  defmacro __using__(_opts \\ []) do
    quote do
      @behaviour DoorFrame.Handler

      def validate_scope(scope) when is_binary(scope) do
        scopes = scope |> String.trim() |> String.split(" ")
        {:ok, scopes}
      end

      def validate_scope(nil), do: {:ok}

      def generate_access_token(_client, _resource_owner) do
        {:ok, DoorFrame.Helper.generate_token()}
      end

      def generate_refresh_token(_client, _resource_owner) do
        {:ok, DoorFrame.Helper.generate_token()}
      end

      defoverridable validate_scope: 1,
                     generate_access_token: 2,
                     generate_refresh_token: 2
    end
  end
end
