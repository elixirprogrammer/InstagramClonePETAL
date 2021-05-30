defmodule InstagramCloneWeb.UserLive.FollowComponent do
  use InstagramCloneWeb, :live_component

  alias InstagramClone.Accounts

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
      class="focus:outline-none">

      <span class="while-submitting">
        <span class="<%= @follow_btn_styles %> inline-flex items-center transition ease-in-out duration-150 cursor-not-allowed">
          <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-gray-300" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          Saving
        </span>
      </span>

      <span class="<%= @follow_btn_styles %>"><%= @follow_btn_name %><span>
    </button>
    """
  end

  @impl true
  def handle_event("toggle-status", _params, socket) do
    current_user = socket.assigns.current_user
    user = socket.assigns.user

    :timer.sleep(300)
    if Accounts.following?(current_user.id, user.id) do
      unfollow(socket, current_user.id, user.id)
    else
      follow(socket, current_user, user)
    end
  end

  defp get_btn_status(socket, assigns) do
    if Accounts.following?(assigns.current_user.id, assigns.user.id) do
      get_socket_assigns(socket, assigns, "Unfollow", "user-profile-unfollow-btn")
    else
      get_socket_assigns(socket, assigns, "Follow", "user-profile-follow-btn")
    end
  end

  defp get_socket_assigns(socket, assigns, btn_name, btn_styles) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(follow_btn_name: btn_name)
      |> assign(follow_btn_styles: btn_styles)}
  end

  defp follow(socket, current_user, user) do
    updated_user = Accounts.create_follow(current_user, user, current_user)
    # Message sent to the parent liveview to update totals
    send(self(), {__MODULE__, :update_totals, updated_user})
    {:noreply,
      socket
      |> assign(follow_btn_name: "Unfollow")
      |> assign(follow_btn_styles: "user-profile-unfollow-btn")}
  end

  defp unfollow(socket, current_user_id, user_id) do
    updated_user = Accounts.unfollow(current_user_id, user_id)
    # Message sent to the parent liveview to update totals
    send(self(), {__MODULE__, :update_totals, updated_user})
    {:noreply,
      socket
      |> assign(follow_btn_name: "Follow")
      |> assign(follow_btn_styles: "user-profile-follow-btn")}
  end

end
