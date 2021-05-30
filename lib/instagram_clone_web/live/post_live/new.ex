defmodule InstagramCloneWeb.PostLive.New do
  use InstagramCloneWeb, :live_view

  alias InstagramClone.Posts.Post
  alias InstagramClone.Posts
  alias InstagramClone.Uploaders.Post, as: PostUploader

  @extension_whitelist ~w(.jpg .jpeg .png)

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)

    {:ok,
      socket
      |> assign(page_title: "New Post")
      |> assign(changeset: Posts.change_post(%Post{}))
      |> allow_upload(:photo_url,
      accept: @extension_whitelist,
      max_file_size: 30_000_000)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      Posts.change_post(%Post{}, post_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    post = PostUploader.put_image_url(socket, %Post{})

    case Posts.create_post(post, post_params, socket.assigns.current_user) do
      {:ok, %{post: post}} ->
        PostUploader.save(socket)

        send_msg(post)

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: Routes.live_path(socket, InstagramCloneWeb.PostLive.Show, post.url_id))}

      {:error, :post, %Ecto.Changeset{} = changeset, %{}} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo_url, ref)}
  end

  defp send_msg(post) do
    # Broadcast to that new post was added
    InstagramCloneWeb.Endpoint.broadcast_from(
      self(),
      Posts.pubsub_topic,
      "new_post",
      %{
        post: post
      }
    )
  end
end
