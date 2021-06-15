defmodule InstagramClone.Likes do
  import Ecto.Query, warn: false
  alias InstagramClone.Repo
  alias InstagramClone.Likes.Like
  alias InstagramClone.Notifications

  def create_like(user, liked) do
    built_user = Ecto.build_assoc(user, :likes)
    like = Ecto.build_assoc(liked, :likes, built_user)
    update_total_likes = liked.__struct__ |> where(id: ^liked.id)
    liked_name_atom = get_struct_name_to_atom(liked)
    notification = get_built_notification(user, liked, liked_name_atom)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:like, like)
    |> Ecto.Multi.insert(:notification, notification)
    |> Ecto.Multi.update_all(:update_total_likes, update_total_likes, inc: [total_likes: 1])
    |> Repo.transaction()
  end

  def unlike(user_id, liked) do
    like = liked?(user_id, liked.id)
    update_total_likes = liked.__struct__ |> where(id: ^liked.id)
    liked_name_atom = get_struct_name_to_atom(liked)
    notification = get_notification(user_id, liked, liked_name_atom)

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:like, like)
    |> Ecto.Multi.delete(:notification, notification)
    |> Ecto.Multi.update_all(:update_total_likes, update_total_likes, inc: [total_likes: -1])
    |> Repo.transaction()
  end

  # Returns nil if not found
  def liked?(user_id, liked_id) do
    Repo.get_by(Like, [user_id: user_id, liked_id: liked_id])
  end

  defp get_built_notification(user, liked, :post) do
    Notifications.build_post_notification(
      actor: user,
      post: liked
    )
  end

  defp get_built_notification(user, liked, :comment) do
    Notifications.build_comment_like_notification(
      actor: user,
      comment: liked
    )
  end

  defp get_notification(user_id, liked, :post) do
    Notifications.get_post_notification(
      actor_id: user_id,
      post: liked
    )
  end

  defp get_notification(user_id, liked, :comment) do
    Notifications.get_post_notification(
      actor_id: user_id,
      comment: liked
    )
  end

  defp get_struct_name_to_atom(liked) do
    liked.__struct__
    |> to_string()
    |> String.split(".")
    |> List.last
    |> String.downcase
    |> String.to_atom
  end
end
