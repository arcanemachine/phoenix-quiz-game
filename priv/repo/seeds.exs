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

  # create generic quiz
  {:ok, generic_quiz} =
    Quizzes.create_quiz(
      %{
        user_id: user.id,
        name: "Example Quiz",
        subject: :other
      },
      unsafe: true
    )

  # create example cards for generic quiz
  Quizzes.create_card(
    %{
      quiz_id: generic_quiz.id,
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
      quiz_id: generic_quiz.id,
      format: :number_entry,
      question: "What is 1 + 1?",
      correct_answer: "2"
    },
    unsafe: true
  )

  Quizzes.create_card(
    %{
      quiz_id: generic_quiz.id,
      format: :text_entry,
      question: "How do you spell the number 1 as a word?",
      correct_answer: "one"
    },
    unsafe: true
  )

  Quizzes.create_card(
    %{
      quiz_id: generic_quiz.id,
      format: :true_or_false,
      question: "2 is larger than 1",
      correct_answer: "true"
    },
    unsafe: true
  )

  # create quiz records for generic quiz
  Quizzes.create_record(%{
    quiz_id: generic_quiz.id,
    user_id: user.id,
    display_name: user.display_name,
    card_count: 4,
    score: 3
  })

  Quizzes.create_record(%{
    quiz_id: generic_quiz.id,
    user_id: nil,
    display_name: "Anonymous Seed User",
    card_count: 4,
    score: 4
  })

  # create math quiz
  Quizzes.create_quiz(
    %{
      user_id: user.id,
      name: "Math Quiz",
      subject: :math,
      math_random_question_count: 3,
      math_random_question_operations: [:add, :subtract, :multiply],
      math_random_question_value_min: -3,
      math_random_question_value_max: 3
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
        name: "Other Quiz",
        subject: :other
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

  # create quiz with no cards
  {:ok, _quiz_with_no_cards} =
    Quizzes.create_quiz(
      %{
        user_id: other_user.id,
        name: "Quiz With No Cards",
        subject: :other
      },
      unsafe: true
    )
end
