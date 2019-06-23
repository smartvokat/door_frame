defmodule DoorFrame.Response do
  defstruct client: nil,
            resource_owner: nil,
            status: nil,
            access_token: nil,
            token_type: nil,
            expires_in: nil
end
