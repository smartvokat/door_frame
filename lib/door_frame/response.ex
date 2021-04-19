defmodule DoorFrame.Response do
  alias DoorFrame.Response

  @type t() :: %__MODULE__{
          access_token: binary(),
          client: any(),
          expires_in: integer(),
          refresh_token: binary(),
          resource_owner: any(),
          scope: any(),
          status: integer(),
          token_type: binary()
        }

  defstruct access_token: nil,
            client: nil,
            expires_in: nil,
            refresh_token: nil,
            resource_owner: nil,
            scope: nil,
            status: 200,
            token_type: "bearer"

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

  def get_expires_in(%Response{} = response, opts \\ []) do
    cond do
      is_map(response.access_token) && Keyword.has_key?(opts, :expires_in) ->
        Map.get(response.access_token, Keyword.get(opts, :expires_in))

      true ->
        response.expires_in
    end
  end
end
