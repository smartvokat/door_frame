# DoorFrame

**NOTE: This library is not production-ready yet.**

DoorFrame is an flexible framework to implement your own OAuth service provider. It provides all the necessary building blocks for different grants.

Features

* Supports authorization code, client credentials, refresh token and password grant, as well as extension grants, with scopes out of the box
* Unopinionated about storage and HTTP integration
* Fully compliant with [RFC 6749](https://tools.ietf.org/html/rfc6749) and [RFC 6750](https://tools.ietf.org/html/rfc6750)
* Very well tested

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `door_frame` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:door_frame, "~> 0.1.0"}
  ]
end
```

```elixir
config :my_app, My.App.Auth,
       access_token_lifetime: 60 * 60 * 4
       refresh_token_lifetime: 60 * 60 * 24 * 14
```

## Quick Start

```elixir
defmodule My.App.Auth do
  use DoorFrame, otp_app: :my_app

  # ...implement callbacks
end
```

```elixir
request =
  My.App.Auth.create_request(
    grant_type: "client_credentials",
    client_id: "a_client",
    client_secret: "secret"
  )

case My.App.Auth.token(request) do
  {:ok, response} ->
    IO.inspect(response.access_token)

  {:error, error} ->
    IO.inspect(error)
end
```

### Plug

```elixir
request = DoorFrame.Adapter.Plug.to_request(conn)

case My.App.Auth.token(request) do
  {:ok, response} ->
    DoorFrame.Adapter.Plug.to_response(conn, response)

  {:error, error} ->
    DoorFrame.Adapter.Plug.to_response(conn, error)
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/doorframe](https://hexdocs.pm/doorframe).
