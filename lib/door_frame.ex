defmodule DoorFrame do
  @moduledoc """
  Documentation for DoorFrame.
  """

  alias DoorFrame.Request
  alias DoorFrame.Response
  alias DoorFrame.Context
  alias DoorFrame.Error
  # alias DoorFrame.Response

  @default_context [
    available_grant_types: %{
      "client_credentials" => DoorFrame.GrantType.ClientCredentials
    }
  ]

  def create_context(fields \\ []) do
    struct(Context, Keyword.merge(@default_context, fields))
  end

  def create_request(fields \\ []) do
    struct(Request, fields)
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
        context.available_grant_types[request.grant_type].handle(context, request, %Response{})
    end
  end
end
