defmodule InstagramClone.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :action, :string
      add :read, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all)
      add :actor_id, references(:users, on_delete: :delete_all)
      add :comment_id, references(:comments, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)

      timestamps()
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:actor_id])
    create index(:notifications, [:comment_id])
    create index(:notifications, [:post_id])
  end
end
