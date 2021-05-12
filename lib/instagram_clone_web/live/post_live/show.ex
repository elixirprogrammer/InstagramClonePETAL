defmodule InstagramCloneWeb.PostLive.Show do
  use InstagramCloneWeb, :live_view

  alias InstagramClone.Posts
  alias InstagramClone.Uploaders.Avatar
  alias InstagramCloneWeb.PostLive.LikeComponent
  alias InstagramClone.Comments
  alias InstagramClone.Comments.Comment

  @impl true
  def mount(%{"id" => id}, session, socket) do
    socket = assign_defaults(session, socket)
    post = Posts.get_post_by_url!(URI.decode(id))

    {:ok,
      socket
      |> assign(changeset: Comments.change_comment(%Comment{}))
      |> assign(comments_section_update: "prepend")
      |> assign(post: post)
      |> assign(page: 1, per_page: 15)
      |> assign_comments()
      |> set_load_more_comments_btn(),
      temporary_assigns: [comments: []]}
  end

  defp assign_comments(socket) do
    current_user = socket.assigns.current_user

    if current_user do
      comments = Comments.list_post_comments(socket.assigns, public: false)
      socket |> assign(comments: comments)
    else
      comments = Comments.list_post_comments(socket.assigns, public: true)
      socket |> assign(comments: comments)
    end
  end

  defp set_load_more_comments_btn(socket) do
    post_total_comments = socket.assigns.post.total_comments
    per_page = socket.assigns.per_page

    if post_total_comments > per_page do
      socket |> assign(load_more_comments_btn: "flex")
    else
      socket |> assign(load_more_comments_btn: "hidden")
    end
  end

  @impl true
  def handle_info({LikeComponent, :update_comment_likes, comment_id}, socket) do
    comment = Comments.get_comment!(comment_id)
    {:noreply,
      socket
      |> update(:comments, fn comments -> [comment | comments] end)}
  end

  @impl true
  def handle_info({LikeComponent, :update_post_likes, post_id}, socket) do
    {:noreply,
      socket
      |> assign(post: Posts.get_post!(post_id))}
  end

  @impl true
  def handle_event("load-more-comments", _, socket) do
    {:noreply,
      socket
      |> assign(comments_section_update: "append")
      |> load_comments()}
  end

  @impl true
  def handle_event("save", %{"comment" => comment_param}, socket) do
    %{"body" => body} = comment_param
    current_user = socket.assigns.current_user
    post = socket.assigns.post

    if body == "" do
      {:noreply, socket}
    else
      comment = Comments.create_comment(current_user, post, comment_param)
      {:noreply,
        socket
        |> update(:comments, fn comments -> [comment | comments] end)
        |> assign(comments_section_update: "prepend")
        |> assign(changeset: Comments.change_comment(%Comment{}))}
    end
  end

  defp load_comments(socket) do
    total_comments = socket.assigns.post.total_comments
    page = socket.assigns.page
    per_page = socket.assigns.per_page
    total_pages = ceil(total_comments / per_page)

    socket
    |> hide_btn?(page, total_pages)
    |> update(:page, &(&1 + 1))
    |> assign_comments()
  end

  defp hide_btn?(socket, page, total_pages) do
    if (page + 1) == total_pages do
      socket |> assign(load_more_comments_btn: "hidden")
    else
      socket
    end
  end
end
