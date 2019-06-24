defmodule DoorFrame do
  @moduledoc """
  Documentation for DoorFrame.
  """

  alias DoorFrame.Request
  alias DoorFrame.Response
  alias DoorFrame.Context
  alias DoorFrame.Error

  @callback validate_scope(any()) :: {:ok, any()} | {:error, atom}
  @callback generate_access_token(any(), any()) :: {:ok, any()} | {:error, atom}
  @callback generate_refresh_token(any(), any()) :: {:ok, any()} | {:error, atom}

  defmacro __using__(opts \\ []) do
    otp_app = Keyword.get(opts, :otp_app)

    quote do
      @behaviour DoorFrame

      @default_context [
        handler: __MODULE__,
        available_grant_types: %{
          "client_credentials" => DoorFrame.GrantType.ClientCredentials
        }
      ]

      @doc """
      Fetches the configuration for this module
      """
      @spec config() :: Keyword.t()
      def config,
        do:
          unquote(otp_app)
          |> Application.get_env(__MODULE__, [])
          |> Keyword.merge(unquote(opts))

      def validate_scope(scope) when is_binary(scope) do
        scopes = scope |> String.trim() |> String.split(" ")
        {:ok, scopes}
      end

      def validate_scope(nil), do: {:ok}

      def generate_access_token(_client, _resource_owner) do
        {:ok, DoorFrame.generate_token()}
      end

      def generate_refresh_token(_client, _resource_owner) do
        {:ok, DoorFrame.generate_token()}
      end

      def create_context(fields \\ []) do
        default_config = Keyword.merge(@default_context, config())
        struct(Context, Keyword.merge(default_config, fields))
      end

      @spec create_request(any) :: %{:__struct__ => atom, optional(atom) => any}
      def create_request(fields \\ []) do
        struct(Request, fields)
      end

      def token(%Request{} = request) do
        token(create_context(), request)
      end

      def token(%Context{} = context, %Request{} = request) do
        cond do
          !Map.has_key?(context.available_grant_types, request.grant_type) ->
            {:error, Error.invalid_grant()}

          is_nil(context.available_grant_types[request.grant_type]) ->
            {:error, Error.server_error("Invalid handler configuration")}

          is_nil(context.handler) ->
            {:error, Error.server_error("No auth handler defined")}

          true ->
            context.available_grant_types[request.grant_type].handle(
              context,
              request,
              %Response{}
            )
        end
      end

      defoverridable validate_scope: 1,
                     generate_access_token: 2,
                     generate_refresh_token: 2
    end
  end

  @doc """
  Generates a random token with URL and filename safe alphabet.

      iex> Token.generate_token()
      "MPjl2Y5AkvtP30rFb3ABRwkYNWsuRhJX"
      iex> Token.generate_token(20)
      "XpT7OoqccDKg8Oa14B5w"
  """
  @spec generate_token(integer) :: String.t()
  def generate_token(length \\ 32) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> String.slice(0, length)
  end
end
