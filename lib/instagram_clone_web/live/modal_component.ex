defmodule InstagramCloneWeb.ModalComponent do
  use InstagramCloneWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div
      class="fixed top-0 left-0 flex items-center justify-center w-full h-screen bg-black bg-opacity-50 z-50"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="<%= @myself %>"
      phx-page-loading>

      <div class="<%= @width %> h-auto bg-white rounded-xl shadow-xl">
        <%= live_patch raw("&times;"), to: @return_to, class: "float-right text-gray-500 text-4xl px-4" %>
        <%= live_component @socket, @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
