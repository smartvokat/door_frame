defmodule DoorFrame.GrantType.Password do
  @moduledoc """
  The resource owner password credentials grant type is suitable in
   cases where the resource owner has a trust relationship with the
   client, such as the device operating system or a highly privileged application.

  **Note: This grant type must only be used by confidential clients.**

  See https://tools.ietf.org/html/rfc6749.html#section-4.3
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
         {:ok, response} <- Base.get_resource_owner(request, response),
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

      is_nil(request.username) ->
        {:error, Error.invalid_request("No username provided")}

      is_nil(request.password) ->
        {:error, Error.invalid_request("No password provided")}

      true ->
        {:ok}
    end
  end
end
