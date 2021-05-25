# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     InstagramClone.Repo.insert!(%InstagramClone.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Query, warn: false

alias InstagramClone.{Repo, Accounts}
alias InstagramClone.Accounts.{User, Follows}
alias InstagramClone.Posts
alias InstagramClone.Posts.Post
alias InstagramClone.Likes
alias InstagramClone.Likes.Like
alias InstagramClone.Comments
alias InstagramClone.Comments.Comment


# Deletes all users
Repo.delete_all(User)
# Creates users
for n <- 1..40 do
  generate_full_name =
    Faker.Person.name
    |> String.replace([".", "'"], "", global: true)

  generate_username =
    Faker.Person.name
    |> String.replace([".", "'", " "], "", global: true)

  attrs = %{
    "email" => "faker#{n}@fake.com",
    "full_name" => generate_full_name,
    "username" => "#{generate_username}#{n}",
    "website" => "https://elixirprogrammer.com",
    "bio" => Faker.Lorem.paragraph(1..2),
    "password" => "secret"
  }

  %User{}
  |> User.registration_changeset(attrs)
  |> Repo.insert!()
end

# Gets all users
users = Repo.all(User)

# Gets random users to be followers
rand_followers = fn (user) ->
  limit_n = Enum.random(5..15)

  User
  |> where([u], u.id != ^user.id)
  |> order_by(desc: fragment("Random()"))
  |> limit(^limit_n)
  |> Repo.all()
end

# Deletes all follows
Repo.delete_all(Follows)
# Adds random follows to all users
for user <- users do
  for follower <- rand_followers.(user) do
    Accounts.create_follow(follower, user, follower)
  end
end

# Deletes all posts
Repo.delete_all(Post)
# Creates posts for all users
for user <- users do
  range_start = Enum.random(8..15)
  range_last = Enum.random(20..25)

  for _ <- range_start..range_last do
    attrs = %{
      "description" => Faker.Lorem.paragraph(1..2),
      "photo_url" => "https://picsum.photos/id/#{:rand.uniform(500)}/900"
    }

    Posts.create_post(%Post{}, attrs, user)
  end
end

# Gets all posts
posts = Posts.list_posts

# Gets random users to given number range to be likers or commenters
rand_users = fn (range) ->
  limit_n = Enum.random(range)

  User
  |> order_by(desc: fragment("Random()"))
  |> limit(^limit_n)
  |> Repo.all()
end

# Deletes all likes
Repo.delete_all(Like)
# Adds likes to all posts
for post <- posts do
  for user <- rand_users.(1..3) do
    Likes.create_like(user, post)
  end
end

# Deletes all comments
Repo.delete_all(Comment)
# Adds comments to all posts
for post <- posts do
  for user <- rand_users.(1..2) do
    attrs = %{"body" => Faker.Lorem.paragraph(1..2)}
    Comments.create_comment(user, post, attrs)
  end
end
