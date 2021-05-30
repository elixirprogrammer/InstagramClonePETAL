defmodule InstagramCloneWeb.PostLive.BookmarkComponent do
  use InstagramCloneWeb, :live_component

  alias InstagramClone.Posts

  @impl true
  def update(assigns, socket) do
    get_btn_status(socket, assigns)
  end

  @impl true
  def render(assigns) do
    ~L"""
    <button
      phx-target="<%= @myself %>"
      phx-click="toggle-status"
      class="h-8 w-8 ml-auto focus:outline-none">

      <%= @icon %>

    </button>
    """
  end

  @impl true
  def handle_event("toggle-status", _params, socket) do
    current_user = socket.assigns.current_user
    post = socket.assigns.post
    bookmarked? = Posts.bookmarked?(current_user.id, post.id)

    if bookmarked? do
      unbookmark(socket, bookmarked?)
    else
      bookmark(socket, current_user, post)
    end
  end

  defp unbookmark(socket, bookmarked?) do
    Posts.unbookmark(bookmarked?)

    {:noreply,
      socket
      |> assign(icon: bookmark_icon(socket.assigns))}
  end

  defp bookmark(socket, current_user, post) do
    Posts.create_bookmark(current_user, post)

    {:noreply,
      socket
      |> assign(icon: bookmarked_icon(socket.assigns))}
  end

  defp get_btn_status(socket, assigns) do
    if assigns.current_user.id in assigns.post.posts_bookmarks do
      get_socket_assigns(socket, assigns, bookmarked_icon(assigns))
    else
      get_socket_assigns(socket, assigns, bookmark_icon(assigns))
    end
  end

  defp get_socket_assigns(socket, assigns, icon) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(icon: icon)}
  end

  defp bookmark_icon(assigns) do
    ~L"""
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
    </svg>
    """
  end

  defp bookmarked_icon(assigns) do
    ~L"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
      <path d="M5 4a2 2 0 012-2h6a2 2 0 012 2v14l-5-2.5L5 18V4z" />
    </svg>
    """
  end

end
