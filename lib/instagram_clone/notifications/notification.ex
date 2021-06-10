defmodule InstagramClone.Notifications.Notification do
  use Ecto.Schema

  schema "notifications" do
    field :action, :string
    field :read, :boolean, default: false
    belongs_to :user, InstagramClone.Accounts.User
    belongs_to :actor, InstagramClone.Accounts.User
    belongs_to :comment, InstagramClone.Comments.Comment
    belongs_to :post, InstagramClone.Posts.Post

    timestamps()
  end

end
