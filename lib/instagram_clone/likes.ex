defmodule InstagramClone.Likes do
  import Ecto.Query, warn: false
  alias InstagramClone.Repo
  alias InstagramClone.Likes.Like

  def create_like(user, liked) do
    user = Ecto.build_assoc(user, :likes)
    like = Ecto.build_assoc(liked, :likes, user)
    update_total_likes = liked.__struct__ |> where(id: ^liked.id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:like, like)
    |> Ecto.Multi.update_all(:update_total_likes, update_total_likes, inc: [total_likes: 1])
    |> Repo.transaction()
  end

  def unlike(user_id, liked) do
    like = get_like(user_id, liked)
    update_total_likes = liked.__struct__ |> where(id: ^liked.id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:like, like)
    |> Ecto.Multi.update_all(:update_total_likes, update_total_likes, inc: [total_likes: -1])
    |> Repo.transaction()
  end


  # Returns nil if not found
  defp get_like(user_id, liked) do
    Enum.find(liked.likes, fn l ->
      l.user_id == user_id
    end)
  end
end
