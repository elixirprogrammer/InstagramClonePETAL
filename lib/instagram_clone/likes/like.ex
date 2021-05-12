defmodule InstagramClone.Likes.Like do
  use Ecto.Schema

  schema "likes" do
    field :liked_id, :integer
    belongs_to :user, InstagramClone.Accounts.User

    timestamps()
  end
end
