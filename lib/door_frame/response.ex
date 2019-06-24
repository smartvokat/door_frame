defmodule DoorFrame.Response do
  defstruct client: nil,
            resource_owner: nil,
            status: 200,
            access_token: nil,
            access_token_string: nil,
            refresh_token: nil,
            refresh_token_string: nil,
            token_type: "bearer",
            expires_in: nil,
            scope: nil
end
