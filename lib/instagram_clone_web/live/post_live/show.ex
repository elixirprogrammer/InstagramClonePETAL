defmodule InstagramCloneWeb.PostLive.Show do
  use InstagramCloneWeb, :live_view

  alias InstagramClone.Posts

  @impl true
  def mount(%{"id" => id}, session, socket) do
    socket = assign_defaults(session, socket)
    post = Posts.get_post_by_url!(URI.decode(id))

    {:ok, socket |> assign(post: post)}
  end
end
