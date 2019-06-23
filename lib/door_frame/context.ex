defmodule DoorFrame.Context do
  defstruct available_grant_types: %{},
            handler: nil,
            access_token_lifetime: 60 * 60 * 4,
            refresh_token_lifetime: 60 * 60 * 24 * 14

  def put_handler(context, handler) do
    Map.put(context, :handler, handler)
  end
end
