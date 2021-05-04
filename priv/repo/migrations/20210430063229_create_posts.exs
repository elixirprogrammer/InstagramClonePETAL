defmodule InstagramClone.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :url_id, :string
      add :description, :text
      add :photo_url, :string
      add :total_likes, :integer, default: 0
      add :total_comments, :integer, default: 0
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:posts, [:user_id])
    create unique_index(:posts, [:url_id])
  end
end
