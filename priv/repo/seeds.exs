# import Ecto.Query

alias QuizGame.Quizzes
# alias QuizGame.Quizzes.{Card, Quiz}
# alias QuizGame.Users.User
alias QuizGame.Users

if Application.get_env(:quiz_game, :server_environment) == :dev do
  # create admin user
  {:ok, admin_user} =
    Users.register_user(%{
      username: "admin",
      email: "admin@example.com",
      password: "password"
    })

  Users.update_user_is_admin(admin_user, true)

  # create non-admin user
  {:ok, non_admin_user} =
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

  # create example quiz
  {:ok, quiz} =
    Quizzes.create_quiz(
      %{
        user_id: non_admin_user.id,
        name: "Example Quiz"
      },
      unsafe: true
    )

  # # create quizzes for all generated users (except the primary user)
  # user_ids = Repo.all(from u in User, select: u.id)

  # for user_id <- user_ids do
  #   if user_id != primary_user.id do
  #     for i <- Enum.random(0..3) do
  #       Quizzes.create_quiz(%{
  #         name: "Quiz ##{user_id}.#{i}"
  #         user_id: user_id,
  #       })
  #     end
  #   end
  # end

  # create example cards
  Quizzes.create_card(
    %{
      quiz_id: quiz.id,
      format: :multiple_choice,
      question: "What is 2 + 2?",
      choice_1: "2",
      choice_2: "4",
      choice_3: "6",
      choice_4: "8",
      correct_answer: "2"
    },
    unsafe: true
  )

  Quizzes.create_card(
    %{
      quiz_id: quiz.id,
      format: :true_or_false,
      question: "2 is larger than 1",
      correct_answer: "true"
    },
    unsafe: true
  )

  Quizzes.create_card(
    %{
      quiz_id: quiz.id,
      format: :text_entry,
      question: "How do you spell the number 1 using letters?",
      correct_answer: "one"
    },
    unsafe: true
  )

  Quizzes.create_card(
    %{
      quiz_id: quiz.id,
      format: :number_entry,
      question: "What is 1 + 1?",
      correct_answer: "2"
    },
    unsafe: true
  )

  # # create cards for all generated quizzes
  # quiz_ids = Repo.all(from q in Quiz, select: q.id)

  # for user_id <- user_ids, quiz_id <- quiz_ids do
  #   Quizzes.create_card(%{
  #     user_id: user_id,
  #     content: %{}
  #   })
  # end
end
