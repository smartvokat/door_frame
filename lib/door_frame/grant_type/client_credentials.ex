defmodule DoorFrame.GrantType.ClientCredentials do
  @moduledoc """
  The client can request an access token using only its client credentials when
  requesting access to the protected resources under its control.

  **Note: This grant type must only be used by confidential clients.**

  See https://tools.ietf.org/html/rfc6749.html#section-4.4

  This grant type uses the following methods from the handler:
  * generate_access_token
  * get_client(client_id, client_secret)
  * get_user
  * persist_access_token
  * validate_scope
  """
  alias DoorFrame.Context
  alias DoorFrame.Error
  alias DoorFrame.Request
  alias DoorFrame.Response

  def handle(%Context{} = context, %Request{} = request, %Response{} = response) do
    with {:ok} <- validate_request(context, request),
         {:ok, request} <- validate_scope(context, request),
         {:ok, response} <- get_client(context, request, response),
         {:ok, response} <- get_resource_owner(context, request, response),
         {:ok, response} <- generate_token(:access_token, context, request, response),
         {:ok, response} <- generate_token(:refresh_token, context, request, response),
         {:ok, response} <- persist_tokens(context, request, response) do
      {:ok, response}
    else
      {:error, %Error{}} = result -> result
      _ -> raise "Na"
    end
  end

  defp validate_request(_context, request) do
    cond do
      is_nil(request.client_id) ->
        {:error, Error.invalid_client("No client_id provided")}

      is_nil(request.client_secret) ->
        {:error, Error.invalid_client("No client_secret provided")}

      true ->
        {:ok}
    end
  end

  defp validate_scope(context, request) do
    case context.handler.validate_scope(request.scope) do
      {:ok} -> {:ok, request}
      {:ok, scope} -> {:ok, Map.put(request, :scope, scope)}
      {:error, description} -> {:error, Error.invalid_scope(description)}
      {:error} -> {:error, Error.invalid_scope()}
    end
  end

  defp get_client(context, request, response) do
    case context.handler.get_client(request.client_id, request.client_secret) do
      {:ok, client} -> {:ok, Map.put(response, :client, client)}
      {:error, description} -> {:error, Error.invalid_client(description)}
      {:error} -> {:error, Error.invalid_client()}
    end
  end

  defp get_resource_owner(context, _request, response) do
    case context.handler.get_resource_owner(response.client) do
      {:ok, resource_owner} -> {:ok, Map.put(response, :resource_owner, resource_owner)}
      {:error, description} -> {:error, Error.invalid_client(description)}
      {:error} -> {:error, Error.invalid_client()}
    end
  end

  defp generate_token(type, context, request, response) do
    case context.handler.generate_token(type, request, response, context) do
      {:ok, token} ->
        {:ok, Map.put(response, type, token)}

      {:error, description} ->
        {:error, Error.server_error(description)}

      {:error} ->
        {:error, Error.server_error()}
    end
  end

  defp persist_tokens(context, _request, response) do
    tokens = %{access_token: response.access_token, refresh_token: response.refresh_token}

    case context.handler.persist_tokens(tokens, response) do
      {:ok} ->
        {:ok, response}

      {:error, description} ->
        {:error, Error.server_error(description)}

      {:error} ->
        {:error, Error.server_error()}
    end
  end
end
