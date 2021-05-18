defmodule InstagramClone.Comments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query, warn: false
  alias InstagramClone.Repo
  alias InstagramClone.Likes.Like
  alias InstagramClone.Comments.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  def list_post_comments(assigns, public: public) do
    user = assigns.current_user
    post_id = assigns.post.id
    per_page = assigns.per_page
    page = assigns.page
    likes_query = Like |> select([l], l.user_id)

    Comment
    |> where(post_id: ^post_id)
    |> get_post_comments_sorting(public, user)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> preload([:user, likes: ^likes_query])
    |> Repo.all
  end

  defp get_post_comments_sorting(module, public, user) do
    if public do
      order_by(module, asc: :id)
    else
      order_by(module, fragment("(CASE WHEN user_id = ? then 1 else 2 end)", ^user.id))
    end
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id) do
    likes_query = Like |> select([l], l.user_id)

    Repo.get!(Comment, id)
    |> Repo.preload([:user, likes: likes_query])
  end

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(user, post, attrs \\ %{}) do
    update_total_comments = post.__struct__ |> where(id: ^post.id)
    comment_attrs = %Comment{} |> Comment.changeset(attrs)
    comment =
      comment_attrs
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Ecto.Changeset.put_assoc(:post, post)

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:update_total_comments, update_total_comments, inc: [total_comments: 1])
    |> Ecto.Multi.insert(:comment, comment)
    |> Repo.transaction()
    |> case do
      {:ok, %{comment: comment}} ->
        likes_query = Like |> select([l], l.user_id)
        comment |> Repo.preload(likes: likes_query)
    end
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
