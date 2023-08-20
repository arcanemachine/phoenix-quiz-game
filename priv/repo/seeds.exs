# import Ecto.Query

alias QuizGame.Quizzes
# alias QuizGame.Quizzes.{Card, Quiz}
# alias QuizGame.Users.User
alias QuizGame.Users

if Application.get_env(:quiz_game, :server_environment) == :dev do
  # ADMIN USER #
  # create admin user
  {:ok, admin_user} =
    Users.register_user(%{
      username: "admin",
      display_name: "Admin",
      email: "admin@example.com",
      password: "password"
    })

  Users.update_user_is_admin(admin_user, true)

  # USER/QUIZ #
  # create user
  {:ok, user} =
    Users.register_user(%{
      username: "user",
      display_name: "User",
      email: "user@example.com",
      password: "password"
    })

  # create quiz for user
  {:ok, quiz} =
    Quizzes.create_quiz(
      %{
        user_id: user.id,
        name: "Example Quiz"
      },
      unsafe: true
    )

  # create example cards for user's quiz
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

  # OTHER USER/QUIZ #
  # create other user
  {:ok, other_user} =
    Users.register_user(%{
      username: "other_user",
      display_name: "Other User",
      email: "other_user@example.com",
      password: "password"
    })

  # create quiz for other user
  {:ok, other_quiz} =
    Quizzes.create_quiz(
      %{
        user_id: other_user.id,
        name: "Other Quiz"
      },
      unsafe: true
    )

  # create example card for other user's quiz
  Quizzes.create_card(
    %{
      quiz_id: other_quiz.id,
      format: :true_or_false,
      question: "Other question",
      correct_answer: "true"
    },
    unsafe: true
  )
end
