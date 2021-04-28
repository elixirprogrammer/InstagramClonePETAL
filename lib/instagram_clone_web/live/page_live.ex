defmodule InstagramCloneWeb.PageLive do
  use InstagramCloneWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply,
      socket
      |> assign(live_action: apply_action(socket.assigns.current_user))}
  end

  defp apply_action(current_user) do
    if !current_user, do: :root_path
  end
end
