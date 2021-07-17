defmodule InstagramClone.Likes do
  import Ecto.Query, warn: false
  alias InstagramClone.Repo
  alias InstagramClone.Likes.Like
  alias InstagramClone.Notifications
  alias InstagramCloneWeb.UserAuth

  def create_like(user, liked) do
    built_user = Ecto.build_assoc(user, :likes)
    like = Ecto.build_assoc(liked, :likes, built_user)
    update_total_likes = liked.__struct__ |> where(id: ^liked.id)
    liked_name_atom = get_struct_name_to_atom(liked)
    notification = get_built_notification(user, liked, liked_name_atom)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:like, like)
    |> Ecto.Multi.update_all(:update_total_likes, update_total_likes, inc: [total_likes: 1])
    |> Repo.transaction()
    |> case do
      {:ok, %{like: _}} ->
        if user.id !== liked.user_id do
          Repo.insert(notification)
          notify_user()
        end
    end
  end

  def unlike(user_id, liked) do
    like = liked?(user_id, liked.id)
    update_total_likes = liked.__struct__ |> where(id: ^liked.id)
    liked_name_atom = get_struct_name_to_atom(liked)

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:like, like)
    |> Ecto.Multi.update_all(:update_total_likes, update_total_likes, inc: [total_likes: -1])
    |> Repo.transaction()
    |> case do
      {:ok, %{like: _}} ->
        if user_id !== liked.user_id do
          notification = get_notification(user_id, liked, liked_name_atom)
          Repo.delete(notification)
          unnotify_user()
        end
    end
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
    Notifications.get_comment_like_notification(
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

  defp notify_user do
    InstagramCloneWeb.Endpoint.broadcast_from(
      self(),
      UserAuth.pubsub_topic(),
      "notify_user",
      %{}
    )
  end

  defp unnotify_user do
    InstagramCloneWeb.Endpoint.broadcast_from(
      self(),
      UserAuth.pubsub_topic(),
      "unnotify_user",
      %{}
    )
  end
end
