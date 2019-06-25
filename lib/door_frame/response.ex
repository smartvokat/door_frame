defmodule DoorFrame.Response do
  alias DoorFrame.Response

  defstruct client: nil,
            resource_owner: nil,
            status: 200,
            access_token: nil,
            refresh_token: nil,
            token_type: "bearer",
            expires_in: nil,
            scope: nil

  def get_access_token(%Response{} = response, opts \\ []) do
    cond do
      is_map(response.access_token) && Keyword.has_key?(opts, :access_token) ->
        Map.get(response.access_token, Keyword.get(opts, :access_token))

      true ->
        response.access_token
    end
  end

  def get_refresh_token(%Response{} = response, opts \\ []) do
    cond do
      is_map(response.refresh_token) && Keyword.has_key?(opts, :refresh_token) ->
        Map.get(response.refresh_token, Keyword.get(opts, :refresh_token))

      true ->
        response.refresh_token
    end
  end
end
