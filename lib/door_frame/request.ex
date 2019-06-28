defmodule DoorFrame.Request do
  defstruct access_token_lifetime: 60 * 60 * 4,
            available_grant_types: %{},
            client_id: nil,
            client_secret: nil,
            grant_type: nil,
            handler: nil,
            password: nil,
            refresh_token_lifetime: 60 * 60 * 24 * 14,
            scope: nil,
            username: nil
end
