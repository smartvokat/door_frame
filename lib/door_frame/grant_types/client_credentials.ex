defmodule DoorFrame.GrantTypes.ClientCredentials do
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
end
