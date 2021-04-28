defmodule InstagramClone.Accounts.Follows do
  use Ecto.Schema

  alias InstagramClone.Accounts.User

  schema "accounts_follows" do
    belongs_to :follower, User
    belongs_to :followed, User

    timestamps()
  end
end
