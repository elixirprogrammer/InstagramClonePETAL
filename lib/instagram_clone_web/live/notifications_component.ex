defmodule InstagramCloneWeb.NotificationsComponent do
  use InstagramCloneWeb, :live_component

  alias InstagramClone.Uploaders.Avatar
  alias InstagramClone.Notifications

  @impl true
  def update(assigns, socket) do
    notification_action = assigns.notification.action
    action_atom = String.to_atom(notification_action)

    {:ok,
      socket
      |> assign(assigns)
      |> assign_notification(action_atom)
      |> assign(action_atom: action_atom)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <%= get_list_type(assigns, @action_atom) %>
    """
  end

  defp assign_notification(socket, :following) do
    notification = socket.assigns.notification

    socket |> assign(notification: notification)
  end

  defp assign_notification(socket, :post_like) do
    notification = socket.assigns.notification
    notification = Notifications.set_preload(notification, :post_like)

    socket |> assign(notification: notification)
  end

  defp assign_notification(socket, :comment_like) do
    notification = socket.assigns.notification
    notification = Notifications.set_preload(notification, :comment_like)

    socket |> assign(notification: notification)
  end

  defp assign_notification(socket, :comment) do
    notification = socket.assigns.notification
    notification = Notifications.set_preload(notification, :comment)

    socket |> assign(notification: notification)
  end

  defp get_list_type(assigns, :following) do
    ~L"""
    <li class="flex items-center px-4 py-3">
      <%= live_redirect to: Routes.user_profile_path(@socket, :index, @notification.actor.username), class: "w-10" do %>
        <%= img_tag Avatar.get_thumb(@notification.actor.avatar_url), class: "w-9 h-9 rounded-full object-cover object-center" %>
      <% end %>
      <div class="mx-2 w-4/5">
        <%= live_redirect to: Routes.user_profile_path(@socket, :index, @notification.actor.username) do %>
          <span class="font-bold text-sm text-gray-500">
            <%= @notification.actor.username %>
          </span>
          <span>started following you.</span>
          <span class="text-gray-400 text-xs">
            <%= Timex.from_now(@notification.inserted_at) %>
          </span>
        <% end %>
      </div>
      <div class="ml-auto">
        <%= live_component @socket,
          InstagramCloneWeb.UserLive.FollowComponent,
          id: @notification.id,
          user: @notification.actor,
          current_user: @current_user %>
      </div>
    </li>
    """
  end

  defp get_list_type(assigns, :post_like) do
    ~L"""
    <li class="flex items-center px-4 py-3">
      <%= live_redirect to: Routes.user_profile_path(@socket, :index, @notification.actor.username), class: "w-10" do %>
        <%= img_tag Avatar.get_thumb(@notification.actor.avatar_url), class: "w-9 h-9 rounded-full object-cover object-center" %>
      <% end %>
      <div class="mx-2 w-4/5">
        <%= live_redirect to: Routes.user_profile_path(@socket, :index, @notification.actor.username) do %>
          <span class="font-bold text-sm text-gray-500">
            <%= @notification.actor.username %>
          </span>
        <% end %>
        <%= live_redirect to: Routes.live_path(@socket, InstagramCloneWeb.PostLive.Show, @notification.post.url_id) do %>
          <span>liked your photo.</span>
          <span class="text-gray-400 text-xs">
            <%= Timex.from_now(@notification.inserted_at) %>
          </span>
        <% end %>
      </div>
      <%= live_redirect to: Routes.live_path(@socket, InstagramCloneWeb.PostLive.Show, @notification.post.url_id), class: "ml-auto w-11" do %>
        <%= img_tag @notification.post.photo_url, class: "w-10 h-10 object-cover object-center" %>
      <% end %>
    </li>
    """
  end

  defp get_list_type(assigns, :comment_like) do
    ~L"""
    <li class="flex items-center px-4 py-3">
      <%= live_redirect to: Routes.user_profile_path(@socket, :index, @notification.actor.username), class: "w-10" do %>
        <%= img_tag Avatar.get_thumb(@notification.actor.avatar_url), class: "w-9 h-9 rounded-full object-cover object-center" %>
      <% end %>
      <div class="mx-2 w-4/5">
        <%= live_redirect to: Routes.user_profile_path(@socket, :index, @notification.actor.username) do %>
          <span class="font-bold text-sm text-gray-500">
            <%= @notification.actor.username %>
          </span>
        <% end %>
        <%= live_redirect to: Routes.live_path(@socket, InstagramCloneWeb.PostLive.Show, @notification.post.url_id) do %>
          <span>
            liked your comment: <%= @notification.comment.body %>
          </span>
          <span class="text-gray-400 text-xs">
            <%= Timex.from_now(@notification.inserted_at) %>
          </span>
        <% end %>
      </div>
      <%= live_redirect to: Routes.live_path(@socket, InstagramCloneWeb.PostLive.Show, @notification.post.url_id), class: "ml-auto w-11" do %>
        <%= img_tag @notification.post.photo_url, class: "w-10 h-10 object-cover object-center" %>
      <% end %>
    </li>
    """
  end

  defp get_list_type(assigns, :comment) do
    ~L"""
    <li class="flex items-center px-4 py-3">
      <%= live_redirect to: Routes.user_profile_path(@socket, :index, @notification.actor.username), class: "w-10" do %>
        <%= img_tag Avatar.get_thumb(@notification.actor.avatar_url), class: "w-9 h-9 rounded-full object-cover object-center" %>
      <% end %>
      <div class="mx-2 w-4/5">
        <%= live_redirect to: Routes.user_profile_path(@socket, :index, @notification.actor.username) do %>
          <span class="font-bold text-sm text-gray-500">
            <%= @notification.actor.username %>
          </span>
        <% end %>
        <%= live_redirect to: Routes.live_path(@socket, InstagramCloneWeb.PostLive.Show, @notification.post.url_id) do %>
          <span>
            commented: <%= @notification.comment.body %>
          </span>
          <span class="text-gray-400 text-xs">
            <%= Timex.from_now(@notification.inserted_at) %>
          </span>
        <% end %>
      </div>
      <%= live_redirect to: Routes.live_path(@socket, InstagramCloneWeb.PostLive.Show, @notification.post.url_id), class: "ml-auto w-11" do %>
        <%= img_tag @notification.post.photo_url, class: "w-10 h-10 object-cover object-center" %>
      <% end %>
    </li>
    """
  end
end
