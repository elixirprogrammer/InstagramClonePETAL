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
      {:ok, _post} ->
        PostUploader.save(socket)

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: Routes.user_profile_path(socket, :index, socket.assigns.current_user.username))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo_url, ref)}
  end
end
