defmodule AuthHandler do
  # use DoorFrame.AuthHandler

  def generate_access_token(_params) do
  end

  # def generate_refresh_token() do
  # end

  # def generate_authorization_code() do
  # end

  def get_authorization_code() do
  end

  def get_client(_client) do

  end
  def get_user(_user) do
  end

  def persist_access_token(_token) do
  end

  def persist_refresh_token(_refresh_token) do
  end

  def persist_authorization_code(_authorization_code) do
  end

  def revoke_authorization_code() do
  end

  def validate_scope() do
  end

  def validate(%{"grant_type" => "client_credentials"}) do
    {:ok}
  end
end