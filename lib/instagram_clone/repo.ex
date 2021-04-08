defmodule InstagramClone.Repo do
  use Ecto.Repo,
    otp_app: :instagram_clone,
    adapter: Ecto.Adapters.Postgres
end
