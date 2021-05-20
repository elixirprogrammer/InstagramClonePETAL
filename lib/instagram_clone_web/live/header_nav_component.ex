defmodule InstagramCloneWeb.HeaderNavComponent do
  use InstagramCloneWeb, :live_component

  alias InstagramClone.Uploaders.Avatar

  @impl true
  def mount(socket) do
    {:ok,
      socket
      |> assign(while_searching_users?: false)
      |> assign(users_not_found?: false)
      |> assign(overflow_y_scroll_ul: "")
      |> assign(searched_users: [])}
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
