defmodule InstagramCloneWeb.LiveHelpers do
  import Phoenix.LiveView
  alias InstagramClone.Accounts
  alias InstagramClone.Accounts.User
  alias InstagramCloneWeb.UserAuth
  alias InstagramClone.Notifications

  defmacro __using__(_opts) do
    quote do
      import InstagramCloneWeb.LiveHelpers

      @impl true
      def handle_info(%{event: "logout_user", payload: %{user: %User{id: id}}}, socket) do
        with %User{id: ^id} <- socket.assigns.current_user do
          {:noreply,
            socket
            |> redirect(to: "/")
            |> put_flash(:info, "Logged out successfully.")}
        else
          _any -> {:noreply, socket}
        end
      end

      @impl true
      def handle_info(%{event: "notify_user", payload: %{}}, socket) do
        send_update(InstagramCloneWeb.HeaderNavComponent,
          id: 1,
          current_user: socket.assigns.current_user,
          unread_notifications?: true
        )

        {:noreply, socket}
      end

      @impl true
      def handle_info(%{event: "unnotify_user", payload: %{}}, socket) do
        send_update(InstagramCloneWeb.HeaderNavComponent,
          id: 1,
          current_user: socket.assigns.current_user,
          unread_notifications?: false
        )

        {:noreply, socket}
      end

      @impl true
      def handle_info({InstagramCloneWeb.HeaderNavComponent, :search_users_event, search}, socket) do
        case Accounts.search_users(search) do
          [] ->
            send_update(InstagramCloneWeb.HeaderNavComponent,
              id: 1,
              searched_users: [],
              users_not_found?: true,
              while_searching_users?: false
            )

            {:noreply, socket}

          users ->
            send_update(InstagramCloneWeb.HeaderNavComponent,
              id: 1,
              searched_users: users,
              users_not_found?: false,
              while_searching_users?: false,
              overflow_y_scroll_ul: check_search_result(users)
            )

            {:noreply, socket}
        end
      end

      @impl true
      def handle_info({InstagramCloneWeb.HeaderNavComponent, :get_notifications, unread_notifications?}, socket) do
        case Notifications.list_user_notifications(socket.assigns.current_user.id) do
          [] ->
            send_update(InstagramCloneWeb.HeaderNavComponent,
              id: 1,
              notifications: [],
              while_searching_notifications?: false,
              current_user: socket.assigns.current_user
            )

            {:noreply, socket}

          notifications ->
            if unread_notifications? do
              Notifications.read(socket.assigns.current_user.id)
            end

            send_update(InstagramCloneWeb.HeaderNavComponent,
              id: 1,
              notifications: notifications,
              while_searching_notifications?: false,
              current_user: socket.assigns.current_user
            )

            {:noreply, socket}
        end
      end

      defp check_search_result(users) do
        if length(users) > 6, do: "overflow-y-scroll", else: ""
      end
    end
  end

  def assign_defaults(session, socket) do
    if connected?(socket), do: InstagramCloneWeb.Endpoint.subscribe(UserAuth.pubsub_topic())

    socket =
      assign_new(socket, :current_user, fn ->
        find_current_user(session)
      end)
    socket
  end

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end

end
