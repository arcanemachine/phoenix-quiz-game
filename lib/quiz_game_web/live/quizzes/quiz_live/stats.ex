defmodule QuizGameWeb.Quizzes.QuizLive.Stats do
  use QuizGameWeb, :live_view

  import Ecto.Query
  import QuizGameWeb.Components.Quizzes

  alias QuizGame.Quizzes.Quiz
  alias QuizGame.Repo
  alias QuizGameWeb.{Endpoint, Presence}
  alias QuizGameWeb.Quizzes.QuizLive.Take

  @presence_topic "quiz_presence"

  @impl true
  def mount(params, _session, socket) do
    quiz = _get_quiz_or_404(params)

    # presence
    if connected?(socket), do: Endpoint.subscribe(@presence_topic)

    {:ok,
     assign(socket,
       page_title: "Quiz Live Stats",
       page_subtitle: quiz.name,
       connected: connected?(socket),
       quiz: quiz
     )
     |> _assign_presence_data()}

    # |> _assign_recently_completed_users(presence_data)}
  end

  defp _get_quiz_or_404(params) do
    Repo.one!(from q in Quiz, where: q.id == ^params["quiz_id"])
  end

  def _assign_presence_data(socket) do
    presence_data = Presence.list_data_for(@presence_topic, socket.assigns.quiz.id)

    if !connected?(socket) do
      socket
      |> push_event("update", %{})
      |> assign(
        presence_data: []
        # presence_users_not_yet_started: [],
        # presence_users_in_progress: [],
        # presence_users_completed: []
      )
    else
      socket
      |> push_event("update-quiz-presence", %{})
      |> assign(
        presence_data: presence_data
        # presence_users_not_yet_started:
        #   _get_presence_users_by_quiz_state(presence_data, :enter_display_name) ++
        #     _get_presence_users_by_quiz_state(presence_data, :before_start),
        # presence_users_in_progress:
        #   _get_presence_users_by_quiz_state(presence_data, :in_progress),
        # presence_users_completed: _get_presence_users_by_quiz_state(presence_data, :completed)
      )
    end
  end

  # defp _get_presence_users_by_quiz_state(presence_data, quiz_state) do
  #   Enum.filter(presence_data, fn data -> data.quiz_state == quiz_state end)
  # end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, socket |> _assign_presence_data()}
  end

  # @impl true
  # def render2(assigns) do
  #   ~H"""
  #   <div class="text-center">
  #     <div class="min-h-[10rem]">
  #       <div class="text-xl font-bold">
  #         Users in the quiz lobby (<%= length(@presence_users_not_yet_started) %>)
  #       </div>
  #       <div class="mt-1 text-center">
  #         <%= if !@connected do %>
  #           <div class="italic">No users are preparing to take this quiz.</div>
  #         <% else %>
  #           <%= if Enum.empty?(@presence_users_not_yet_started) do %>
  #             <div class="italic">No users are preparing to take this quiz.</div>
  #           <% else %>
  #             <div class="flex flex-wrap">
  #               <%= for data <- @presence_users_not_yet_started do %>
  #                 <._user_detail_card data={data} current_user={@current_user} />
  #               <% end %>
  #             </div>
  #           <% end %>
  #         <% end %>
  #       </div>
  #     </div>
  #     <div class="min-h-[10rem]">
  #       <div class="mt-12 text-xl font-bold">
  #         Users taking this quiz (<%= length(@presence_users_in_progress) %>)
  #       </div>
  #       <div class="mt-1 text-center">
  #         <%= if !@connected do %>
  #           <div class="italic">No users are taking this quiz.</div>
  #         <% else %>
  #           <%= if Enum.empty?(@presence_users_in_progress) do %>
  #             <div class="italic">No users are taking this quiz.</div>
  #           <% else %>
  #             <div class="flex flex-wrap">
  #               <%= for data <- @presence_users_in_progress do %>
  #                 <._user_detail_card data={data} current_user={@current_user} />
  #               <% end %>
  #             </div>
  #           <% end %>
  #         <% end %>
  #       </div>
  #     </div>
  #     <div class="min-h-[10rem]">
  #       <div class="mt-12 text-xl font-bold">
  #         Recently-completed users (<%= length(@presence_users_completed) %>)
  #       </div>
  #       <div class="mt-1 text-center">
  #         <%= if !@connected || Enum.empty?(@presence_users_completed) do %>
  #           <div class="italic">No users have recently completed this quiz.</div>
  #         <% else %>
  #           <div class="flex flex-wrap gap-4">
  #             <%= for data <- @presence_users_completed do %>
  #               <._user_detail_card data={data} current_user={@current_user} />
  #             <% end %>
  #           </div>
  #         <% end %>
  #       </div>
  #     </div>
  #   </div>

  #   <.action_links class="mt-12">
  #     <.action_links_item kind="back">
  #       <.link href={route(:quizzes, :show, quiz_id: @quiz.id)}>
  #         Return to quiz
  #       </.link>
  #     </.action_links_item>
  #   </.action_links>
  #   """
  # end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="text-center">
      <div class="min-h-[10rem]">
        <div class="text-xl font-bold">
          Users in the quiz lobby (<%= length(@presence_data) %>)
        </div>
        <div class="mt-1 text-center">
          <div class="flex flex-wrap">
            <%= for data <- @presence_data do %>
              <._user_detail_card
                data={data}
                show={"#{data.quiz_state in [:enter_display_name, :before_start]}"}
              />
            <% end %>
          </div>
        </div>
      </div>
      <div class="min-h-[10rem]">
        <div class="mt-12 text-xl font-bold">
          Users taking this quiz (<%= length(@presence_data) %>)
        </div>
        <div class="mt-1 text-center">
          <div class="flex flex-wrap">
            <%= for data <- @presence_data do %>
              <._user_detail_card data={data} show={"#{data.quiz_state == :in_progress}"} />
            <% end %>
          </div>
        </div>
      </div>
      <div class="min-h-[10rem]">
        <div class="mt-12 text-xl font-bold">
          Recently-completed users (<%= length(@presence_data) %>)
        </div>
        <div class="mt-1 text-center">
          <div class="flex flex-wrap gap-4">
            <%= for data <- @presence_data do %>
              <._user_detail_card data={data} show={"#{data.quiz_state == :completed}"} />
            <% end %>
          </div>
        </div>
      </div>
    </div>

    <.action_links class="mt-12">
      <.action_links_item kind="back">
        <.link href={route(:quizzes, :show, quiz_id: @quiz.id)}>
          Return to quiz
        </.link>
      </.action_links_item>
    </.action_links>
    """
  end

  attr :data, :any, required: true
  attr :show, :string, required: true

  defp _user_detail_card(assigns) do
    ~H"""
    <div
      class="mt-2 mx-auto px-2 card w-full max-w-md bg-secondary/10 border border-secondary/5
             shadow-lg shadow-secondary/10"
      data-show={@show}
      x-data="{ show: false }"
      x-title="user-detail-card"
      x-collapse.duration.500ms
      x-show="show && $el.dataset.show === 'true'"
      x-init="$nextTick(() => { show = true }"
      x-on:phx:update-quiz-presence.window="show = $el.dataset.show === 'true'"
    >
      <div class="card-body">
        <%!-- name --%>
        <div>
          <%= if @data.user do %>
            <%= @data.user.display_name %> (username: <%= @data.user.username %>)
          <% else %>
            <%= @data.display_name || raw("<i>No name yet</i>") %> (<i>unauthenticated</i>)
          <% end %>
        </div>

        <%!-- quiz progress and score info --%>
        <%= if Enum.member?([:in_progress, :completed], @data.quiz_state) do %>
          <div class="mt-1">
            <.quiz_progress
              percent_completed={
                Take.get_percent_completed_as_integer(@data.current_card_index, @data.quiz_length)
              }
              percent_correct={
                Take.get_total_percent_correct_as_integer(@data.score, @data.quiz_length)
              }
            />
          </div>

          <div class="mt-1">
            <b>
              <%= Take.get_score_percent_as_integer(@data.score, @data.current_card_index) %>%
            </b>
            - <%= @data.score %> / <%= @data.current_card_index %> correct
            <%= if @data.quiz_state == :in_progress do %>
              (<%= @data.quiz_length - @data.current_card_index %> remaining)
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
