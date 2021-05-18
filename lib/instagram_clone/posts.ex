defmodule InstagramClone.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias InstagramClone.Repo

  alias InstagramClone.Posts.Post
  alias InstagramClone.Accounts.User
  alias InstagramClone.Comments.Comment
  alias InstagramClone.Likes.Like

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Returns the list of paginated posts of a given user id.

  ## Examples

      iex> list_user_posts(page: 1, per_page: 10, user_id: 1)
      [%{photo_url: "", url_id: ""}, ...]

  """
  def list_profile_posts(page: page, per_page: per_page, user_id: user_id) do
    Post
    |> select([p], map(p, [:url_id, :photo_url]))
    |> where(user_id: ^user_id)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> order_by(desc: :id)
    |> Repo.all
  end

  @doc """
  Returns the list of paginated posts of a given user id
  And posts of following list of given user id
  With user and likes preloaded
  With 2 most recent comments preloaded with user and likes
  User, page, and per_page are given with the socket assigns

  ## Examples

      iex> get_accounts_feed(following_list, assigns)
      [%{photo_url: "", url_id: ""}, ...]

  """
  def get_accounts_feed(following_list, assigns) do
    user = assigns.current_user
    page = assigns.page
    per_page = assigns.per_page
    query =
      from c in Comment,
      select: %{id: c.id, row_number: over(row_number(), :posts_partition)},
      windows: [posts_partition: [partition_by: :post_id, order_by: [desc: :id]]]
    comments_query =
      from c in Comment,
      join: r in subquery(query),
      on: c.id == r.id and r.row_number <= 2
    likes_query = Like |> select([l], l.user_id)

    Post
    |> where([p], p.user_id in ^following_list)
    |> or_where([p], p.user_id == ^user.id)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> order_by(desc: :id)
    |> preload([:user, likes: ^likes_query, comments: ^{comments_query, [:user, likes: likes_query]}])
    |> Repo.all()
  end

  def get_accounts_feed_total(following_list, assigns) do
    user = assigns.current_user

    Post
    |> where([p], p.user_id in ^following_list)
    |> or_where([p], p.user_id == ^user.id)
    |> select([p], count(p.id))
    |> Repo.one()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    likes_query = Like |> select([l], l.user_id)

    Repo.get!(Post, id)
    |> Repo.preload([:user, likes: likes_query])
  end

  def get_post_feed!(id) do
    query =
      from c in Comment,
      select: %{id: c.id, row_number: over(row_number(), :posts_partition)},
      windows: [posts_partition: [partition_by: :post_id, order_by: [desc: :id]]]
    comments_query =
      from c in Comment,
      join: r in subquery(query),
      on: c.id == r.id and r.row_number <= 2
    likes_query = Like |> select([l], l.user_id)

    Post
    |> preload([:user, likes: ^likes_query, comments: ^{comments_query, [:user, likes: likes_query]}])
    |> Repo.get!(id)
  end

  def get_post_by_url!(id) do
    likes_query = Like |> select([l], l.user_id)

    Repo.get_by!(Post, url_id: id)
    |> Repo.preload([:user, likes: likes_query])
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%Post{} = post, attrs \\ %{}, user) do
    post = Ecto.build_assoc(user, :posts, put_url_id(post))
    changeset = Post.changeset(post, attrs)
    update_posts_count = from(u in User, where: u.id == ^user.id)

    Ecto.Multi.new()
    |> Ecto.Multi.update_all(:update_posts_count, update_posts_count, inc: [posts_count: 1])
    |> Ecto.Multi.insert(:post, changeset)
    |> Repo.transaction()
  end

  # Generates a base64-encoding 8 bytes
  defp put_url_id(post) do
    url_id = Base.encode64(:crypto.strong_rand_bytes(8), padding: false)

    %Post{post | url_id: url_id}
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
