defmodule DoorFrame.Request do
  @type t() :: %__MODULE__{
          access_token_lifetime: integer(),
          available_grant_types: map(),
          client_id: binary(),
          client_secret: binary(),
          context: any(),
          grant_type: binary(),
          handler: any(),
          password: binary(),
          refresh_token_lifetime: integer(),
          scope: any(),
          username: binary()
        }

  defstruct access_token_lifetime: 60 * 60 * 4,
            available_grant_types: %{},
            client_id: nil,
            client_secret: nil,
            context: nil,
            grant_type: nil,
            handler: nil,
            password: nil,
            refresh_token_lifetime: 60 * 60 * 24 * 14,
            scope: nil,
            username: nil
end
