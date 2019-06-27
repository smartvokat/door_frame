defmodule DoorFrame.GrantType.ClientCredentials do
  @moduledoc """
  The client can request an access token using only its client credentials when
  requesting access to the protected resources under its control.

  **Note: This grant type must only be used by confidential clients.**

  See https://tools.ietf.org/html/rfc6749.html#section-4.4
  """
  alias DoorFrame.Error
  alias DoorFrame.Request
  alias DoorFrame.Response

  @spec handle(DoorFrame.Request.t(), DoorFrame.Response.t()) ::
          {:error, DoorFrame.Error.t()} | {:ok, DoorFrame.Response.t()}
  def handle(%Request{} = request, %Response{} = response) do
    with {:ok} <- validate_request(request),
         {:ok, request} <- validate_scope(request),
         {:ok, response} <- get_client(request, response),
         {:ok, response} <- get_resource_owner(request, response),
         {:ok, response} <- generate_token(:access_token, request, response),
         {:ok, response} <- generate_token(:refresh_token, request, response),
         {:ok, response} <- persist_tokens(request, response) do
      {:ok, response}
    else
      {:error, %Error{}} = e -> e
    end
  end

  defp validate_request(request) do
    cond do
      is_nil(request.client_id) ->
        {:error, Error.invalid_request("No client_id provided")}

      is_nil(request.client_secret) ->
        {:error, Error.invalid_request("No client_secret provided")}

      true ->
        {:ok}
    end
  end

  defp validate_scope(request) do
    case request.handler.validate_scope(request.scope) do
      {:ok} -> {:ok, request}
      {:ok, scope} -> {:ok, Map.put(request, :scope, scope)}
      {:error, description} -> {:error, Error.invalid_scope(description)}
      {:error} -> {:error, Error.invalid_scope()}
    end
  end

  defp get_client(request, response) do
    case request.handler.get_client(request.client_id, request.client_secret) do
      {:ok, client} -> {:ok, Map.put(response, :client, client)}
      {:error, description} -> {:error, Error.invalid_client(description)}
      {:error} -> {:error, Error.invalid_client()}
    end
  end

  defp get_resource_owner(request, response) do
    case request.handler.get_resource_owner(response.client) do
      {:ok, resource_owner} -> {:ok, Map.put(response, :resource_owner, resource_owner)}
      {:error, description} -> {:error, Error.invalid_client(description)}
      {:error} -> {:error, Error.invalid_client()}
    end
  end

  defp generate_token(type, request, response) do
    case request.handler.generate_token(type, request, response) do
      {:ok, token} ->
        {:ok, Map.put(response, type, token)}

      {:error, description} ->
        {:error, Error.server_error(description)}

      {:error} ->
        {:error, Error.server_error()}
    end
  end

  defp persist_tokens(request, response) do
    tokens = %{access_token: response.access_token, refresh_token: response.refresh_token}

    case request.handler.persist_tokens(tokens, response) do
      {:ok} ->
        {:ok, response}

      {:error, description} ->
        {:error, Error.server_error(description)}

      {:error} ->
        {:error, Error.server_error()}
    end
  end
end
