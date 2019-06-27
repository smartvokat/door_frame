defmodule DoorFrame do
  @moduledoc """
  Documentation for DoorFrame.
  """

  alias DoorFrame.Request
  alias DoorFrame.Response
  alias DoorFrame.Error

  @callback validate_scope(any()) :: {:ok, any()} | {:error, atom}
  @callback generate_token(atom, DoorFrame.Request.t(), DoorFrame.Response.t()) ::
              {:ok, any()} | {:error, atom}

  defmacro __using__(opts \\ []) do
    otp_app = Keyword.get(opts, :otp_app)

    quote do
      @behaviour DoorFrame

      @default_request [
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

      @doc """
      Checks if the scope is valid
      """
      def validate_scope(scope) when is_binary(scope) do
        scopes = scope |> String.trim() |> String.split(" ")
        {:ok, scopes}
      end

      def validate_scope(nil) do
        {:ok}
      end

      @doc """
      Generates a new token. The type can be `:access_token` or `:refresh_token`
      """
      def generate_token(_type, _request, _response) do
        {:ok, DoorFrame.generate_token()}
      end

      @spec create_request(any) :: DoorFrame.Request.t()
      def create_request(fields \\ []) do
        default_config = Keyword.merge(@default_request, config())
        struct(Request, Keyword.merge(default_config, fields))
      end

      def token(%Request{} = request) do
        cond do
          !Map.has_key?(request.available_grant_types, request.grant_type) ->
            {:error, Error.invalid_grant()}

          is_nil(request.available_grant_types[request.grant_type]) ->
            {:error, Error.server_error("Invalid handler configuration")}

          is_nil(request.handler) ->
            {:error, Error.server_error("No auth handler defined")}

          true ->
            request.available_grant_types[request.grant_type].handle(
              request,
              %Response{}
            )
        end
      end

      defoverridable validate_scope: 1,
                     generate_token: 3
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
