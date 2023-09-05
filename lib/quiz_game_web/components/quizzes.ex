defmodule QuizGameWeb.Components.Quizzes do
  @moduledoc "Provides Phoenix components for the Quizzes context."
  use Phoenix.Component, global_prefixes: ~w(x-)

  @doc """
  Renders the progress bar for a given quiz.

  ## Example

      <.quiz_progress percent_completed={50} />
  """

  attr :percent_correct, :integer,
    required: true,
    doc: "the percentage of the questions that have been answered correctly"

  attr :percent_completed, :integer,
    required: true,
    doc: "the percentage of the quiz that has been completed"

  def quiz_progress(assigns) do
    ~H"""
    <div class="relative w-full">
      <div
        class={[
          "absolute left-0 right-0 bg-error show-empty-element rounded-l-md
           transition-[width] duration-500",
          @percent_completed == 100 && "rounded-r-md"
        ]}
        style={"width: #{@percent_completed}%"}
      />
      <div
        class={[
          "absolute left-0 right-0 bg-success show-empty-element rounded-l-md
          transition-[width] duration-500",
          @percent_correct == 100 && "rounded-r-md"
        ]}
        style={"width: #{@percent_correct}%"}
      />

      <%!-- background container element --%>
      <div class="w-full bg-slate-500 rounded-md show-empty-element" />
    </div>
    """
  end
end
