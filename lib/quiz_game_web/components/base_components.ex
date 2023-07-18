defmodule QuizGameWeb.BaseComponents do
  @moduledoc """
  Provides base UI components.
  """
  use Phoenix.Component, global_prefixes: ~w(x-)
  use QuizGameWeb, :verified_routes

  import QuizGameWeb.CoreComponents

  @doc """
  Renders the page footer.

  ## Example

      <.footer />
  """
  def footer(assigns) do
    ~H"""
    <section class="w-full lg:p-2">
      <%!-- limit max width of footer by nesting it inside a full-width element --%>
      <div class="max-w-[100rem] mx-auto py-6 bg-brand text-slate-300 text-center
                  lg:rounded-box lg:shadow-xl lg:shadow-black/20">
        <ul class="list-none">
          <li>
            <div class="text-xl font-bold">
              Quiz Game
            </div>
          </li>

          <%!-- project links --%>
          <li class="mt-6">
            <.link href={~p"/"} class="!text-slate-300">
              Home
            </.link>
          </li>

          <%!-- extra links --%>
          <li class="mt-6">
            <.link href={~p"/terms-of-use"} class="!text-slate-300">
              Terms of Use
            </.link>
          </li>
          <li class="mt-2">
            <.link href={~p"/privacy-policy"} class="!text-slate-300">
              Privacy Policy
            </.link>
          </li>

          <%!-- legal stuff --%>
          <li class="mt-6 font-bold">
            <small>
              &copy; Copyright <%= DateTime.utc_now().year %>. All rights reserved.
            </small>
          </li>
        </ul>
      </div>
    </section>
    """
  end

  @doc """
  Renders the primary navbar.

  ## Example

      <.navbar />
  """
  def navbar(assigns) do
    ~H"""
    <div class="w-full lg:p-2">
      <%!-- limit max width of navbar by nesting it inside a full-width element --%>
      <nav
        data-component="page-navbar"
        class="navbar max-w-[100rem] mx-auto p-0 bg-brand text-slate-300 lg:rounded-box
               lg:shadow-lg lg:shadow-black/20"
      >
        <%!-- navbar start items --%>
        <div class="flex-1">
          <%!-- navbar title --%>
          <.link navigate="/" class="pl-4 text-2xl !text-slate-300 normal-case btn btn-ghost">
            Quiz Game
          </.link>
        </div>

        <%!-- navbar end items --%>
        <div class="mr-1 flex-none">
          <%!-- user actions menu --%>
          <details class="dropdown dropdown-end" x-data @click.outside="$el.removeAttribute('open')">
            <summary
              class="m-1 btn btn-ghost focus:ring-2"
              x-tooltip="{ content: 'User Actions', placement: 'left' }"
              @focus="$el.removeAttribute('open')"
            >
              <.icon name="hero-user-circle-solid" class="h-7 w-7" />
            </summary>
            <ul class="w-52 p-2 shadow menu dropdown-content bg-base-100 text-base-content
                       n-transition-background rounded-box border-2 border-secondary">
              <div class="mt-2 mb-3 text-lg text-center font-bold">
                User Actions
              </div>
              <%= if assigns[:current_user] do %>
                <li>
                  <.link href={~p"/"}>Your profile</.link>
                </li>
                <li>
                  <.link href={~p"/"}>Log out</.link>
                </li>
              <% else %>
                <li>
                  <.link href={~p"/"}>Register</.link>
                </li>
                <li>
                  <.link href={~p"/"}>Log in</.link>
                </li>
              <% end %>
            </ul>
          </details>

          <%!-- settings menu --%>
          <div
            x-data="{ show: false }"
            x-title="navbar-settings-menu"
            x-on:keyup.escape="show = false"
          >
            <button
              class="btn-ghost btn-square btn m-1"
              x-tooltip="{ content: 'Settings', placement: 'left' }"
              x-on:click="show = true"
            >
              <.icon name="hero-cog-6-tooth-solid" class="h-7 w-7" />
            </button>

            <div class="modal !bg-base-100/50 text-base-content" x-bind:class="show && 'modal-open'">
              <div
                class="relative max-w-xs modal-box border-2 overflow-x-hidden"
                x-show="show"
                x-transition.duration.500ms
                x-trap.inert.noscroll.noreturn="show"
                x-on:click.outside="show = false"
              >
                <div class="mb-12 text-3xl font-bold text-center">Settings</div>
                <button
                  x-on:click="show = false"
                  class="absolute right-0 top-0 btn btn-circle btn-ghost"
                >
                  ✕
                </button>

                <div class="flex justify-between align-center h-12 w-full max-w-xs my-4 ml-1">
                  <div class="w-full my-auto pr-6 text-lg font-semibold text-center">
                    <label for="settings-modal-theme-select">Theme</label>
                  </div>
                  <div x-data="themeSelect" x-title="theme-select">
                    <select
                      id="settings-modal-theme-select"
                      class="select select-bordered"
                      name="theme"
                      x-model="theme"
                      x-on:change="handleChange"
                    >
                      <option>Auto</option>
                      <option>Light</option>
                      <option>Dark</option>
                    </select>
                  </div>
                </div>

                <div class="form-control mt-12 w-full max-w-xs">
                  <button class="btn btn-secondary" x-on:click="show = false">Close</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </nav>
    </div>
    """
  end

  @doc """
  Renders a container element for toast messages.

  ## Example

      <.toast_container />
  """
  def toast_container(assigns) do
    ~H"""
    <section
      id="toast-container"
      x-on:phx:toast-show.window="(evt) => $store.toasts.show(evt.detail)"
      x-on:phx:toast-show-primary.window="(evt) => $store.toasts.showPrimary(evt.detail)"
      x-on:phx:toast-show-secondary.window="(evt) => $store.toasts.showSecondary(evt.detail)"
      x-on:phx:toast-show-accent.window="(evt) => $store.toasts.showAccent(evt.detail)"
      x-on:phx:toast-show-neutral.window="(evt) => $store.toasts.showNeutral(evt.detail)"
      x-on:phx:toast-show-info.window="(evt) => $store.toasts.showInfo(evt.detail)"
      x-on:phx:toast-show-success.window="(evt) => $store.toasts.showSuccess(evt.detail)"
      x-on:phx:toast-show-warning.window="(evt) => $store.toasts.showWarning(evt.detail)"
      x-on:phx:toast-show-error.window="(evt) => $store.toasts.showError(evt.detail)"
    />
    """
  end
end
