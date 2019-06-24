defmodule DoorFrame.Adapter.Plug do
  alias DoorFrame.Request
  alias DoorFrame.Response
  alias DoorFrame.Error

  @spec to_request(Plug.Conn.t()) :: DoorFrame.Request.t()
  def to_request(%Plug.Conn{} = conn) do
    with {:ok, credentials} <- parse_authorization_header(conn),
         {:ok, body_params} <- parse_body(conn) do
      {:ok, struct(Request, Map.merge(credentials, body_params))}
    else
      e -> e
    end
  end

  def to_response(%Plug.Conn{} = conn, %Response{status: status} = response)
      when status >= 200 and status < 300 do
    # TODO: Handle redirects

    payload =
      %{
        token_type: response.token_type,
        access_token: response.access_token_string
      }
      |> put_if(:expires_in, response.expires_in)
      |> put_if(:refresh_token, response.refresh_token_string)
      |> put_if(:scope, response.scope)

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json;charset=UTF-8")
    |> Plug.Conn.resp(status, Jason.encode!(payload))
  end

  def to_response(%Plug.Conn{} = conn, %Error{} = error) do
    payload =
      %{error: error.error}
      |> put_if(:description, error.description)

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json;charset=UTF-8")
    |> Plug.Conn.resp(error.status_code, Jason.encode!(payload))
  end

  defp put_if(map, _key, nil), do: map
  defp put_if(map, key, value), do: Map.put(map, key, value)

  defp parse_body(%Plug.Conn{} = conn) do
    params =
      Enum.reduce(conn.body_params, %{}, fn
        {"grant_type", grant_type}, body_params ->
          Map.put(body_params, :grant_type, grant_type)

        {"client_id", value}, body_params ->
          Map.put(body_params, :client_id, value)

        {"client_secret", value}, body_params ->
          Map.put(body_params, :client_secret, value)

        {"username", value}, body_params ->
          Map.put(body_params, :username, value)

        {"password", value}, body_params ->
          Map.put(body_params, :password, value)

        {"scope", value}, body_params ->
          Map.put(body_params, :scope, value)

        _, body_params ->
          body_params
      end)

    {:ok, params}
  end

  defp parse_authorization_header(%Plug.Conn{} = conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      ["Basic " <> token] ->
        parse_basic_authorization_header(token)

      ["basic " <> token] ->
        parse_basic_authorization_header(token)

      _ ->
        {:error, Error.invalid_request("Missing basic authorization header")}
    end
  end

  defp parse_basic_authorization_header(token) do
    with {:ok, credentials} <- Base.decode64(token),
         [client_id, client_secret] <- String.split(credentials, ":") do
      {:ok, %{client_id: client_id, client_secret: client_secret}}
    else
      _ -> {:error, Error.invalid_request("Malformed authorization header")}
    end
  end
end
