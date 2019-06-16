defmodule DoorFrame.Server do
  use Plug.Router

  import Plug.Conn

  plug :match
  plug :dispatch
  plug Plug.Parsers, parsers: [:urlencoded]

  post "/oauth/token" do
    # - [x] Extract info from request
    #   - [x] `grant_type`, `client_id` && `client_secret`
    # - [x] Validate request
    #   - [x] If invalid, return error
    #   - [x] If valid, return the access token (JWT)

    IO.inspect conn
    IO.inspect conn.body_params

    with {:ok, params} <- read_body(conn),
         {:ok} <- AuthHandler.validate(params) do
      access_token = AuthHandler.generate_access_token(params)

      conn
      |> put_resp_content_type("application/json")
      |> put_req_header("Authorization", access_token)
      |> send_resp(200, "access_token=#{access_token}")
    else
      _ ->  conn |> send_resp(401, "401 Unauthorized")
    end
  end

  # match(_, do: conn)

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello, World!")
  end
end