defmodule InstagramClone.Repo.Migrations.CreatePostsBookmarks do
  use Ecto.Migration

  def change do
    create table(:posts_bookmarks) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)

      timestamps()
    end

    create index(:posts_bookmarks, [:user_id])
    create index(:posts_bookmarks, [:post_id])
  end
end
