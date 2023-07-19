defmodule QuizGameWeb.UserLogoutLive do
  use QuizGameWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Confirm Logout")}
  end

  def render(assigns) do
    ~H"""
    <%= if assigns[:current_user] do %>
      <div class="my-8 text-lg text-center">
        Are you sure you want to log out?
      </div>

      <.simple_form for={%{}} id="logout-form">
        <:actions>
          <.form_button_cancel />
          <.link href={~p"/users/log_out"} id="logout-form-button-submit" method="delete">
            <.form_button tabindex="-1" class="btn-primary" content="Yes" />
          </.link>
        </:actions>
      </.simple_form>
    <% else %>
      <.header class="my-8 text-center">
        You are not currently logged in.
      </.header>

      <.simple_form for={%{}} id="logout-form">
        <:actions>
          <.link href={~p"/"}>
            <.form_button tabindex="-1" class="btn-secondary" content="Home" />
          </.link>
          <.link href={~p"/users/log_in"}>
            <.form_button tabindex="-1" class="btn-primary" content="Login" />
          </.link>
        </:actions>
      </.simple_form>
    <% end %>
    """
  end
end
