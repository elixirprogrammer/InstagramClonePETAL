defmodule InstagramClone.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias InstagramClone.Repo

  alias InstagramClone.Notifications.Notification
  alias InstagramClone.Posts.Post
  alias InstagramClone.Comments.Comment

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
    Repo.all(Notification) |> Repo.preload(:actor)
  end

  def list_user_notifications(user_id) do
    Notification
    |> where(user_id: ^user_id)
    |> where([n], n.inserted_at >= datetime_add(^NaiveDateTime.utc_now(), -1, "week") )
    |> order_by(desc: :id)
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

  def build_following_notification(user: user, actor: actor) do
    user = Ecto.build_assoc(user, :notifications, action: @actions.following_action)
    notification = Ecto.build_assoc(actor, :actors, user)

    notification
  end

  def build_post_notification(actor: actor, post: post) do
    actor =
      Ecto.build_assoc(
        actor,
        :actors,
        action: @actions.post_action,
        user_id: post.user_id
      )
    notification = Ecto.build_assoc(post, :notifications, actor)

    notification
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

  def build_comment_like_notification(actor: actor, comment: comment) do
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

    notification
  end

  def get_following_notification(user_id: user_id, actor_id: actor_id) do
    Repo.get_by!(
      Notification,
      user_id: user_id,
      actor_id: actor_id,
      action: @actions.following_action
    )
  end

  def get_post_notification(actor_id: actor_id, post: post) do
    notification =
      Repo.get_by!(
        Notification,
        user_id: post.user_id,
        actor_id: actor_id,
        post_id: post.id,
        action: @actions.post_action
      )

    notification
  end

  def get_comment_like_notification(actor_id: actor_id, comment: comment) do
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

    notification
  end

  def read(user_id) do
    query = from(n in Notification, where: n.user_id == ^user_id)

    Repo.update_all(query, set: [read: true])
  end

  def get_unread(user_id) do
    Notification
    |> where(user_id: ^user_id)
    |> where(read: false)
    |> Repo.exists?
  end

  def set_preload(notification, :post_like) do
    post_query =
      Post
      |> select([p], %{url_id: p.url_id, photo_url: p.photo_url})

    notification |> Repo.preload(post: post_query)
  end

  def set_preload(notification, :comment_like) do
    set_notification_preload(notification)
  end

  def set_preload(notification, :comment) do
    set_notification_preload(notification)
  end

  defp set_notification_preload(notification) do
    post_query =
      Post
      |> select([p], %{url_id: p.url_id, photo_url: p.photo_url})
    comment_query =
      Comment
      |> select([c], %{body: c.body})

    notification |> Repo.preload(post: post_query, comment: comment_query)
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
