defmodule InstagramClone.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias InstagramClone.Repo

  alias InstagramClone.Notifications.Notification

  @actions %{
    following_action: "following",
    post_action: "post_like",
    comment_action: "comment",
    comment_like_action: "comment_like"
  }

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
  end

  def list_user_notifications(user_id) do
    Notification
    |> where(user_id: ^user_id)
    |> where([n], n.inserted_at >= datetime_add(^NaiveDateTime.utc_now(), -1, "week") )
    |> preload(:actor)
    |> Repo.all
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  def create_following_notification(user: user, actor: actor) do
    user = Ecto.build_assoc(user, :notifications, action: @actions.following_action)
    notification = Ecto.build_assoc(actor, :actors, user)

    Repo.insert(notification)
  end

  def create_post_notification(actor: actor, post: post) do
    actor =
      Ecto.build_assoc(
        actor,
        :actors,
        action: @actions.post_action,
        user_id: post.user_id
      )
    notification = Ecto.build_assoc(post, :notifications, actor)

    Repo.insert(notification)
  end

  def create_comment_notification(actor: actor, post: post, comment: comment) do
    actor =
      Ecto.build_assoc(
        actor,
        :actors,
        action: @actions.comment_action,
        user_id: post.user_id,
        post_id: post.id
      )
    notification = Ecto.build_assoc(comment, :notifications, actor)

    Repo.insert(notification)
  end

  def create_comment_like_notification(actor: actor, comment: comment) do
    preload_post = Repo.preload(comment, :post)
    post = preload_post.post
    actor =
      Ecto.build_assoc(
        actor,
        :actors,
        action: @actions.comment_like_action,
        user_id: comment.user_id,
        post_id: post.id
      )
    notification = Ecto.build_assoc(comment, :notifications, actor)

    Repo.insert(notification)
  end

  def delete_following_notification(user_id: user_id, actor_id: actor_id) do
    notification =
      Repo.get_by!(
        Notification,
        user_id: user_id,
        actor_id: actor_id,
        action: @actions.following_action
      )

    Repo.delete(notification)
  end

  def delete_post_notification(actor_id: actor_id, post: post) do
    notification =
      Repo.get_by!(
        Notification,
        user_id: post.user_id,
        actor_id: actor_id,
        post_id: post.id,
        action: @actions.post_action
      )

    Repo.delete(notification)
  end

  def delete_comment_like_notification(actor_id: actor_id, comment: comment) do
    preload_post = Repo.preload(comment, :post)
    post = preload_post.post
    notification =
      Repo.get_by!(
        Notification,
        user_id: comment.user_id,
        actor_id: actor_id,
        post_id: post.id,
        comment_id: comment.id,
        action: @actions.comment_like_action
      )

    Repo.delete(notification)
  end

  def read do
    Notification
    |> Repo.update_all(set: [read: true])
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

end
