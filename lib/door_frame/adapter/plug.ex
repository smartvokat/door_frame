defmodule DoorFrame.Adapter.Plug do
  alias DoorFrame.Request
  alias DoorFrame.Response
  alias DoorFrame.Error

  @spec to_request(DoorFrame.Request.t(), Plug.Conn.t(), any()) ::
          {:ok, DoorFrame.Request.t()} | {:error, DoorFrame.Error.t()}
  def to_request(%Request{} = request, %Plug.Conn{} = conn, _opts \\ []) do
    with {:ok, credentials} <- parse_authorization_header(conn),
         {:ok, body_params} <- parse_body(conn) do
      {:ok, request |> Map.merge(credentials) |> Map.merge(body_params)}
    else
      e -> e
    end
  end

  def to_response(response_or_error, conn, opts \\ [])

  def to_response(%Response{status: status} = response, %Plug.Conn{} = conn, opts)
      when status >= 200 and status < 300 do
    # TODO: Handle redirects

    payload =
      %{
        token_type: response.token_type,
        access_token: Response.get_access_token(response, opts)
      }
      |> put_if(:expires_in, Response.get_expires_in(response, opts))
      |> put_if(:refresh_token, Response.get_refresh_token(response, opts))
      |> put_if(:scope, response.scope)

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json;charset=UTF-8")
    |> Plug.Conn.resp(status, Jason.encode!(payload))
  end

  def to_response(%Error{} = error, %Plug.Conn{} = conn, _opts) do
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
