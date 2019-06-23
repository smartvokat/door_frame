defmodule DoorFrame.Helper do
  @doc """
  Generates a random token with URL and filename safe alphabet.

      iex> Token.generate_token()
      "MPjl2Y5AkvtP30rFb3ABRwkYNWsuRhJX"
      iex> Token.generate_token(20)
      "XpT7OoqccDKg8Oa14B5w"
  """
  @spec generate_token(integer) :: String.t()
  def generate_token(length \\ 32) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> String.slice(0, length)
  end
end
