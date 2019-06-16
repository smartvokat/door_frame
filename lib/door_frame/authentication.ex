defmodule DoorFrame.Authentication do
  def authenticate(%{grant_type: "authorization_code"}) do
  end

  def authenticate(%{grant_type: "client_credentials"}) do
  end

  def authenticate(%{grant_type: "implicit"}) do    
  end

  # def authenticate(%{grant_type: "authorization_code"}) do
  # end
end