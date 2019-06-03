# DoorFrame

DoorFrame is an flexible framework to implement your own OAuth service provider. It provides all the necessary building blocks for different grants.

Features

* Supports authorization code, client credentials, refresh token and password grant, as well as extension grants, with scopes out of the box
* Unopinionated about storage
* Fully compliant with RFC 6749 and RFC 6750
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
  use DoorFrame.Handler, otp_app: :my_app
end
```

```elixir
My.App.Auth.authenticate()
```

### Plug

```elixir
conn = conn
|> DoorFrame.Adapter.Plug.authenticate(My.App.Auth)
|> send_json()
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/doorframe](https://hexdocs.pm/doorframe).
