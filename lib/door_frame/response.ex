defmodule DoorFrame.Response do
  defstruct client: nil,
            resource_owner: nil,
            status: 200,
            access_token: nil,
            refresh_token: nil,
            token_type: "bearer",
            expires_in: nil,
            scope: nil
end
