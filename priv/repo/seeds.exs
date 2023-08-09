# import Ecto.Query

# alias QuizGame.Quizzes
# alias QuizGame.Quizzes.{Card, Quiz}
# alias QuizGame.Users.User
alias QuizGame.Users

if Application.get_env(:quiz_game, :server_environment) == :dev do
  # create admin user
  {:ok, user} =
    Users.register_user(%{
      username: "admin",
      email: "admin@example.com",
      password: "password"
    })

  Users.update_user_is_admin(user, true)

  # create non-admin user
  Users.register_user(%{
    username: "user",
    email: "user@example.com",
    password: "password"
  })

  # # create other users
  # for i <- 1..5 do
  #   Users.register_user(%{
  #     username: "user#{i}",
  #     email: "user#{i}@example.com",
  #     password: "password#{i}"
  #   })
  # end

  # # create quizzes for all generated users (except the primary user)
  # user_ids = Repo.all(from u in User, select: u.id)

  # for user_id <- user_ids do
  #   if user_id != primary_user.id do
  #     for i <- Enum.random(0..3) do
  #       Quizzes.create_quiz(%{
  #         user_id: user_id,
  #         name: "Quiz ##{user_id}.#{i}"
  #       })
  #     end
  #   end
  # end

  # # create cards for all generated quizzes
  # quiz_ids = Repo.all(from q in Quiz, select: q.id)

  # for user_id <- user_ids, quiz_id <- quiz_ids do
  #   Quizzes.create_card(%{
  #     user_id: user_id,
  #     content: %{}
  #   })
  # end
end
