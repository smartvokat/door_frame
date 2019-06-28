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
  alias DoorFrame.GrantType.Base

  @spec handle(DoorFrame.Request.t(), DoorFrame.Response.t()) ::
          {:error, DoorFrame.Error.t()} | {:ok, DoorFrame.Response.t()}
  def handle(%Request{} = request, %Response{} = response) do
    with {:ok} <- validate_request(request),
         {:ok, request} <- Base.validate_scope(request),
         {:ok, response} <- Base.get_client(request, response),
         {:ok, response} <- Base.get_resource_owner_from_client(request, response),
         {:ok, response} <- Base.generate_token(:access_token, request, response),
         {:ok, response} <- Base.generate_token(:refresh_token, request, response),
         {:ok, response} <- Base.persist_tokens(request, response) do
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
end
