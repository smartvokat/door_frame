defmodule DoorFrame.GrantType.Base do
  @moduledoc false

  alias DoorFrame.Error
  alias DoorFrame.Request
  alias DoorFrame.Response

  @type token_type :: :access_token | :refresh_token

  @spec validate_scope(DoorFrame.Request.t()) ::
          {:error, DoorFrame.Error.t()} | {:ok, DoorFrame.Request.t()}
  def validate_scope(request) do
    case request.handler.validate_scope(request.scope) do
      {:ok} -> {:ok, request}
      {:ok, %Request{} = request} -> {:ok, request}
      {:ok, scope} -> {:ok, Map.put(request, :scope, scope)}
      {:error, description} -> {:error, Error.invalid_scope(description)}
      {:error} -> {:error, Error.invalid_scope()}
    end
  end

  @spec get_client(DoorFrame.Request.t(), DoorFrame.Response.t()) ::
          {:error, DoorFrame.Error.t()} | {:ok, DoorFrame.Response.t()}
  def get_client(request, response) do
    case request.handler.get_client(request, response) do
      {:ok, %Response{} = response} ->
        {:ok, response}

      {:ok, client} ->
        {:ok, Map.put(response, :client, client)}

      {:error, description} when is_binary(description) ->
        {:error, Error.invalid_client(description)}

      {:error, %Error{}} = error ->
        error

      :error ->
        {:error, Error.invalid_client()}

      _ ->
        raise RuntimeError, ~s/Invalid return value for "get_client" callback./
    end
  end

  @spec get_resource_owner_from_client(DoorFrame.Request.t(), DoorFrame.Response.t()) ::
          {:error, DoorFrame.Error.t()} | {:ok, DoorFrame.Response.t()}
  def get_resource_owner_from_client(request, response) do
    if supports?(request.handler, :get_resource_owner_from_client, 2) do
      case request.handler.get_resource_owner_from_client(request, response) do
        {:ok, %Response{} = response} -> {:ok, response}
        {:ok, resource_owner} -> {:ok, Map.put(response, :resource_owner, resource_owner)}
        {:error, description} -> {:error, Error.invalid_client(description)}
        {:error} -> {:error, Error.invalid_client()}
      end
    else
      {:ok, response}
    end
  end

  @spec get_resource_owner(DoorFrame.Request.t(), DoorFrame.Response.t()) ::
          {:error, DoorFrame.Error.t()} | {:ok, DoorFrame.Response.t()}
  def get_resource_owner(request, response) do
    case request.handler.get_resource_owner(request, response) do
      {:ok, %Response{} = response} ->
        {:ok, response}

      {:ok, resource_owner} ->
        {:ok, Map.put(response, :resource_owner, resource_owner)}

      {:error, description} when is_binary(description) ->
        {:error, Error.invalid_grant(description)}

      {:error, %Error{}} = error ->
        error

      :error ->
        {:error, Error.invalid_grant()}

      _ ->
        raise RuntimeError, ~s/Invalid return value for "get_resource_owner" callback./
    end
  end

  @spec generate_token(token_type, DoorFrame.Request.t(), DoorFrame.Response.t()) ::
          {:error, DoorFrame.Error.t()} | {:ok, DoorFrame.Response.t()}
  def generate_token(type, request, response) do
    case request.handler.generate_token(type, request, response) do
      {:ok, %Response{} = response} ->
        {:ok, response}

      {:ok, token} ->
        {:ok, Map.put(response, type, token)}

      {:error, description} ->
        {:error, Error.server_error(description)}

      :error ->
        {:error, Error.server_error()}
    end
  end

  @spec persist_tokens(DoorFrame.Request.t(), DoorFrame.Response.t()) ::
          {:error, DoorFrame.Error.t()} | {:ok, DoorFrame.Response.t()}
  def persist_tokens(request, response) do
    if supports?(request.handler, :persist_tokens, 2) do
      tokens = %{access_token: response.access_token, refresh_token: response.refresh_token}

      case request.handler.persist_tokens(tokens, response) do
        :ok ->
          {:ok, response}

        {:ok, %Response{} = response} ->
          {:ok, response}

        {:error, description} ->
          {:error, Error.server_error(description)}

        :error ->
          {:error, Error.server_error()}
      end
    else
      {:ok, response}
    end
  end

  def supports?(handler, func, arity), do: function_exported?(handler, func, arity)
end
