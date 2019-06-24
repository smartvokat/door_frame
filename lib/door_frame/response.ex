defmodule DoorFrame.Response do
  defstruct client: nil,
            resource_owner: nil,
            status: 200,
            access_token: nil,
            token_type: nil,
            expires_in: nil
end
