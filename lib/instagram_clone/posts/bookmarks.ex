defmodule InstagramClone.Posts.Bookmarks do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts_bookmarks" do
    belongs_to :user, InstagramClone.Accounts.User
    belongs_to :post, InstagramClone.Posts.Post

    timestamps()
  end

end
