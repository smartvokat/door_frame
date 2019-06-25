defmodule DoorFrame.ResponseTest do
  alias DoorFrame.Response

  use ExUnit.Case

  describe "get_access_token()" do
    test "supports a simple string access_token" do
      response = %Response{access_token: "a_token"}
      assert Response.get_access_token(response) == "a_token"
    end

    test "supports a map access_token" do
      response = %Response{access_token: %{string: "a_token"}}
      assert Response.get_access_token(response, access_token: :string) == "a_token"
    end
  end

  describe "get_refresh_token()" do
    test "supports a simple string refresh_token" do
      response = %Response{refresh_token: "a_token"}
      assert Response.get_refresh_token(response) == "a_token"
    end

    test "supports a map refresh_token" do
      response = %Response{refresh_token: %{string: "a_token"}}
      assert Response.get_refresh_token(response, refresh_token: :string) == "a_token"
    end
  end
end
