defmodule DoorFrame.Adapter.Plug do
  alias DoorFrame.Request
  alias DoorFrame.Response

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
    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json;charset=UTF-8")
    |> Plug.Conn.resp(status, Jason.encode!(response))
  end

  defp parse_body(%Plug.Conn{} = conn) do
    params =
      Enum.reduce(conn.body_params, %{}, fn
        {"grant_type", grant_type}, body_params ->
          Map.put(body_params, :grant_type, grant_type)

        # username
        # password
        # …

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
        {:error, :invalid_authorization_header}
    end
  end

  defp parse_basic_authorization_header(token) do
    with {:ok, credentials} <- Base.decode64(token),
         [client_id, client_secret] <- String.split(credentials, ":") do
      {:ok, %{client_id: client_id, client_secret: client_secret}}
    else
      _ -> {:error, :invalid_authorization_header}
    end
  end
end
