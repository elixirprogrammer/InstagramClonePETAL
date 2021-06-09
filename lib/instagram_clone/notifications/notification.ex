defmodule InstagramClone.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :action, :string
    belongs_to :user, InstagramClone.Accounts.User
    belongs_to :actor, InstagramClone.Accounts.User
    belongs_to :comment, InstagramClone.Comments.Comment
    belongs_to :post, InstagramClone.Posts.Post

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:action])
    |> validate_required([:action])
  end
end
