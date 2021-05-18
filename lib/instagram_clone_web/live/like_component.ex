defmodule InstagramCloneWeb.Live.LikeComponent do
  use InstagramCloneWeb, :live_component

  alias InstagramClone.Likes

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
      class="<%= @w_h %> focus:outline-none">

      <%= @icon %>

    </button>
    """
  end

  @impl true
  def handle_event("toggle-status", _params, socket) do
    current_user = socket.assigns.current_user
    liked = socket.assigns.liked

    if Likes.liked?(current_user.id, liked.id) do
      unlike(socket, current_user.id, liked)
    else
      like(socket, current_user, liked)
    end
  end

  defp like(socket, current_user, liked) do
    Likes.create_like(current_user, liked)
    send_msg(liked)

    {:noreply,
      socket
      |> assign(icon: unlike_icon(socket.assigns))}
  end

  defp unlike(socket, current_user_id, liked) do
    Likes.unlike(current_user_id, liked)
    send_msg(liked)

    {:noreply,
      socket
      |> assign(icon: like_icon(socket.assigns))}
  end

  defp send_msg(liked) do
    msg = get_struct_msg_atom(liked)
    send(self(), {__MODULE__, msg, liked})
  end

  defp get_btn_status(socket, assigns) do
    if assigns.current_user.id in assigns.liked.likes do
      get_socket_assigns(socket, assigns, unlike_icon(assigns))
    else
      get_socket_assigns(socket, assigns, like_icon(assigns))
    end
  end

  defp get_socket_assigns(socket, assigns, icon) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(icon: icon)}
  end

  defp get_struct_name(struct) do
    struct.__struct__
    |> Module.split()
    |> List.last()
    |> String.downcase()
  end

  defp get_struct_msg_atom(struct) do
    name = get_struct_name(struct)
    update_struct_likes = "update_#{name}_likes"
    String.to_atom(update_struct_likes)
  end

  defp like_icon(assigns) do
    ~L"""
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
    </svg>
    """
  end

  defp unlike_icon(assigns) do
    ~L"""
    <svg class="text-red-600" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M3.172 5.172a4 4 0 015.656 0L10 6.343l1.172-1.171a4 4 0 115.656 5.656L10 17.657l-6.828-6.829a4 4 0 010-5.656z" clip-rule="evenodd" />
    </svg>
    """
  end

end
