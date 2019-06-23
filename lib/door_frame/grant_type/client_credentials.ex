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
         {:ok, response} <- generate_access_token(context, response),
         {:ok, response} <- generate_refresh_token(context, response),
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

  defp generate_access_token(context, response) do
    case context.handler.generate_access_token(response.client, response.resource_owner) do
      {:ok, token} -> {:ok, Map.put(response, :access_token, token)}
      {:error, description} -> {:error, Error.server_error(description)}
      {:error} -> {:error, Error.server_error()}
    end
  end

  defp generate_refresh_token(context, response) do
    case context.handler.generate_refresh_token(response.client, response.resource_owner) do
      {:ok, token} -> {:ok, Map.put(response, :refresh_token, token)}
      {:error, description} -> {:error, Error.server_error(description)}
      {:error} -> {:error, Error.server_error()}
    end
  end

  defp persist_tokens(context, _request, response) do
    cond do
      Keyword.has_key?(context.handler.__info__(:functions), :persist_tokens) ->
        # TODO: Should we only add the refresh_token when available?
        tokens = %{access_token: response.access_token, refresh_token: response.refresh_token}

        case context.handler.persist_tokens(tokens, response.client, response.resource_owner) do
          {:ok} ->
            {:ok, response}

          {:ok, tokens} ->
            {:ok,
             response
             |> Map.put(:access_token, tokens.access_token)
             |> Map.put(:refresh_token, tokens.refresh_token)}

          {:error, description} ->
            {:error, Error.server_error(description)}

          {:error} ->
            {:error, Error.server_error()}
        end

      true ->
        with {:ok, response} <-
               persist_token(:access_token, response.access_token, context, response),
             {:ok, response} <-
               persist_token(:refresh_token, response.refresh_token, context, response) do
          {:ok, response}
        else
          e -> e
        end
    end
  end

  defp persist_token(type, token, context, response) do
    callback =
      cond do
        type == :access_token ->
          &context.handler.persist_token/3

        type == :refresh_token ->
          &context.handler.persist_token/3

        true ->
          raise "Unknown token type"
      end

    case callback.(Map.put(%{}, type, token), response.client, response.resource_owner) do
      {:ok} -> {:ok, response}
      {:ok, token} -> {:ok, Map.put(response, type, token)}
      {:error, description} -> {:error, Error.server_error(description)}
      {:error} -> {:error, Error.server_error()}
    end
  end
end
