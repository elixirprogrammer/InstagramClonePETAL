defmodule InstagramClone.Repo.Migrations.AddToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string
      add :full_name, :string
      add :avatar_url, :string
      add :bio, :string
      add :website, :string
    end
  end
end
