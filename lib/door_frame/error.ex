defmodule DoorFrame.Error do
  @moduledoc """
  See https://tools.ietf.org/html/rfc6749.html#section-4.1.2.1
  See https://tools.ietf.org/html/rfc6749.html#section-5.2
  """
  alias __MODULE__

  @derive {Jason.Encoder, only: [:error, :description]}

  defstruct status_code: 400, error: nil, description: nil, uri: nil

  @doc """
  The request is missing a required parameter, includes an unsupported
  parameter value (other than grant type), repeats a parameter, includes
  multiple credentials, utilizes more than one mechanism for authenticating
  the client, or is otherwise malformed.
  """
  def invalid_request(description \\ "") do
    %Error{error: "invalid_request", description: description}
  end

  @doc """
  Client authentication failed (e.g., unknown client, no client
  authentication included, or unsupported authentication method)
  """
  def invalid_client(description \\ nil) do
    %Error{status_code: 401, error: "invalid_client", description: description}
  end

  @doc """
  The provided authorization grant (e.g., authorization code,
  resource owner credentials) or refresh token is invalid, expired,
  revoked, does not match the redirection URI used in the authorization
  request, or was issued to another client.
  """
  def invalid_grant(description \\ nil) do
    %Error{error: "invalid_grant", description: description}
  end

  @doc """
  The access token provided is expired, revoked, malformed, or invalid for
  other reasons.
  """
  def invalid_token(description \\ nil) do
    %Error{status_code: 401, error: "invalid_token", description: description}
  end

  @doc """
  The authenticated client is not authorized to use this authorization grant type.
  """
  def unauthorized_client(description \\ nil) do
    %Error{error: "unauthorized_client", description: description}
  end

  @doc """
  The authorization grant type is not supported by the authorization server.
  """
  def unsupported_grant_type(description \\ nil) do
    %Error{error: "unsupported_grant_type", description: description}
  end

  @doc """
  The authorization server does not support obtaining an authorization code
  using this method.
  """
  def unsupported_response_type(description \\ nil) do
    %Error{error: "unsupported_response_type", description: description}
  end

  @doc """
  The requested scope is invalid, unknown, malformed, or exceeds the scope
  granted by the resource owner.
  """
  def invalid_scope(description \\ nil) do
    %Error{error: "invalid_scope", description: description}
  end

  @doc """
  The resource owner or authorization server denied the request.
  """
  def access_denied(description \\ nil) do
    %Error{status_code: 401, error: "access_denied", description: description}
  end

  @doc """
  The authorization server encountered an unexpected condition that prevented
  it from fulfilling the request. (This error code is needed because a 500
  Internal Server Error HTTP status code cannot be returned to the client
  via an HTTP redirect.)
  """
  def server_error(description \\ nil) do
    %Error{status_code: 500, error: "server_error", description: description}
  end

  @doc """
  The authorization server is currently unable to handle the request due to a
  temporary overloading or maintenance of the server. (This error code is
  needed because a 503 Service Unavailable HTTP status code cannot be returned
  to the client via an HTTP redirect.)
  """
  def temporarily_unavailable(description \\ nil) do
    %Error{status_code: 503, error: "temporarily_unavailable", description: description}
  end
end
