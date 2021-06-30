defmodule InstagramCloneWeb.HeaderNavComponent do
  use InstagramCloneWeb, :live_component

  alias InstagramClone.Uploaders.Avatar
  alias InstagramClone.Notifications

  @impl true
  def mount(socket) do
    {:ok,
      socket
      |> assign(while_searching_users?: false)
      |> assign(users_not_found?: false)
      |> assign(overflow_y_scroll_ul: "")
      |> assign(searched_users: [])
      |> assign(notifications: [])
      |> assign(while_searching_notifications?: false)}
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(unread_notifications?: unread_notification?(assigns))}
  end

  defp unread_notification?(assigns) do
    if assigns.current_user do
      Notifications.get_unread(assigns.current_user.id)
    else
      false
    end
  end

  @impl true
  def handle_event("get-notifications", _, socket) do
    unread_notifications? = socket.assigns.unread_notifications?
    send(self(), {__MODULE__, :get_notifications, unread_notifications?})

    {:noreply,
      socket
      |> assign(notifications: [])
      |> assign(while_searching_notifications?: true)}
  end

  @impl true
  def handle_event("search_users", %{"q" => search}, socket) do
    if search == "" do
      {:noreply, socket}
    else
      send(self(), {__MODULE__, :search_users_event, search})

      {:noreply,
        socket
        |> assign(users_not_found?: false)
        |> assign(searched_users: [])
        |> assign(overflow_y_scroll_ul: "")
        |> assign(while_searching_users?: true)}
    end
  end

end
