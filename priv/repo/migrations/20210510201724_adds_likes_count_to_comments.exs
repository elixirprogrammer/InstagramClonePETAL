defmodule InstagramClone.Repo.Migrations.AddsLikesCountToComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :total_likes, :integer, default: 0
    end
  end
end
