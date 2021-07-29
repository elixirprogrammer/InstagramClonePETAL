defmodule InstagramCloneWeb.UserLive.Profile do
  use InstagramCloneWeb, :live_view

  alias InstagramClone.Accounts
  alias InstagramClone.Posts

  @impl true
  def mount(%{"username" => username}, session, socket) do
    socket = assign_defaults(session, socket)
    user = Accounts.profile(username)

    {:ok,
      socket
      |> assign(page: 1, per_page: 15)
      |> assign(user: user)
      |> assign(page_title: "#{user.full_name} (@#{user.username})"),
      temporary_assigns: [posts: []]}
  end

  defp assign_posts(socket) do
    socket
    |> assign(posts:
      Posts.list_profile_posts(
        page: socket.assigns.page,
        per_page: socket.assigns.per_page,
        user_id: socket.assigns.user.id
      )
    )
  end

  defp assign_saved_posts(socket) do
    socket
    |> assign(posts:
      Posts.list_saved_profile_posts(
        page: socket.assigns.page,
        per_page: socket.assigns.per_page,
        user_id: socket.assigns.user.id
      )
    )
  end

  @impl true
  def handle_event("load-more-profile-posts", _, socket) do
    {:noreply, socket |> load_posts}
  end

  defp load_posts(socket) do
    total_posts = get_total_posts_count(socket)
    page = socket.assigns.page
    per_page = socket.assigns.per_page
    total_pages = ceil(total_posts / per_page)

    if page == total_pages do
      socket
    else
      socket
      |> update(:page, &(&1 + 1))
      |> get_posts()
    end
  end

  defp get_total_posts_count(socket) do
    if socket.assigns.saved_page? do
      Posts.count_user_saved(socket.assigns.user)
    else
      socket.assigns.user.posts_count
    end
  end

  defp get_posts(socket) do
    if socket.assigns.saved_page? do
      assign_saved_posts(socket)
    else
      assign_posts(socket)
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action)}
  end

  defp apply_action(socket, :index) do
    selected_link_styles = "text-gray-600 border-t-2 border-black -mt-0.5"
    live_action = get_live_action(socket.assigns.user, socket.assigns.current_user)

    socket
    |> assign(selected_index: selected_link_styles)
    |> assign(selected_saved: "text-gray-400")
    |> assign(saved_page?: false)
    |> assign(live_action: live_action)
    |> show_saved_profile_link?()
    |> assign_posts()
  end

  defp apply_action(socket, :saved) do
    selected_link_styles = "text-gray-600 border-t-2 border-black -mt-0.5"

    socket
    |> assign(selected_index: "text-gray-400")
    |> assign(selected_saved: selected_link_styles)
    |> assign(live_action: :edit_profile)
    |> assign(saved_page?: true)
    |> show_saved_profile_link?()
    |> redirect_when_not_my_saved()
    |> assign_saved_posts()
  end

  defp apply_action(socket, :following) do
    following = Accounts.list_following(socket.assigns.user)
    socket |> assign(following: following)
  end

  defp apply_action(socket, :followers) do
    followers = Accounts.list_followers(socket.assigns.user)
    socket |> assign(followers: followers)
  end

  defp redirect_when_not_my_saved(socket) do
    username = socket.assigns.current_user.username

    if socket.assigns.my_saved? do
      socket
    else
      socket
      |> push_redirect(to: Routes.user_profile_path(socket, :index, username))
    end
  end

  defp show_saved_profile_link?(socket) do
    user = socket.assigns.user
    current_user = socket.assigns.current_user

    if current_user && current_user.id == user.id do
      socket |> assign(my_saved?: true)
    else
      socket |> assign(my_saved?: false)
    end
  end

  defp get_live_action(user, current_user) do
    cond do
      current_user && current_user.id == user.id -> :edit_profile
      current_user -> :follow_component
      true -> :login_btn
    end
  end

end
