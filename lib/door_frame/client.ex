defmodule DoorFrame.Client do
  use Plug.Router

  import Plug.Conn

  plug :match
  plug :dispatch

  # TODO: implement OAuth client endpoints

  match(_, do: conn)
end