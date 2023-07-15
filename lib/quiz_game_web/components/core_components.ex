defmodule QuizGameWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: QuizGameWeb.Endpoint, router: QuizGameWeb.Router

  import QuizGameWeb.Gettext
  alias Phoenix.LiveView.JS

  @doc """
  Renders a list of links.

  ## Example

      <.action_links items={[
        %{content: "Return to your profile", navigate: ~p"/users/profile", class: "list-back"}
      ]} />
  """
  attr :title, :string, default: nil
  attr :class, :string, default: nil
  attr :items, :list, required: true

  def action_links(assigns) do
    ~H"""
    <section class={["mt-12", @class]}>
      <h3 class="text-2xl font-bold">
        <%= @title || "Actions" %>
      </h3>
      <ul class="mt-2 ml-6">
        <li :for={item <- @items} class={[["mt-2 pl-2 list-dash"], [Map.get(item, :class, "")]]}>
          <.link
            href={Map.get(item, :href, false)}
            navigate={Map.get(item, :navigate, false)}
            patch={Map.get(item, :patch, false)}
            method={Map.get(item, :method, "get")}
            data-confirm={Map.get(item, :confirm, false)}
          >
            <%= item.content %>
          </.link>
        </li>
      </ul>
    </section>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :any, default: nil
  attr :loader, :boolean, default: false
  attr :rest, :global, default: %{loader: false}

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button type={@type} class={["btn", @class]} {@rest}>
      <%= if @loader do %>
        <span class="phx-click-loading:hidden phx-submit-loading:hidden">
          <%= render_slot(@inner_block) %>
        </span>
        <.loader />
      <% else %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </button>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :success, :warning, :error], doc: "flash message style"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "w-80 sm:w-96 mx-auto p-3 z-50 rounded-lg ring-1",
        @kind == :info &&
          "bg-info text-info-content ring-info-content fill-info-content shadow-xl",
        @kind == :success &&
          "bg-success text-success-content ring-success-content fill-success-content shadow-xl",
        @kind == :warning &&
          "bg-warning text-warning-content ring-warning-content fill-warning-content shadow-xl",
        @kind == :error &&
          "bg-error text-error-content ring-error-content fill-error-content shadow-xl"
      ]}
      {@rest}
    >
      <div class="flex flex-center">
        <p class="grow px-4 text-sm font-semibold text-center">
          <span :if={@title}><%= @title %>:</span>
          <%= msg %>
        </p>
        <button class="block group" aria-label={gettext("close")}>
          <.icon name="hero-x-mark-solid" class="h-5 w-5 group-hover:opacity-50" />
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  def flash_group(assigns) do
    ~H"""
    <div class="fixed w-screen top-0 right-0 left-0 mt-child-2">
      <.flash kind={:error} title="Error" id="flash-error" flash={@flash} />
      <.flash kind={:warning} title="Warning" id="flash-warning" flash={@flash} />
      <.flash kind={:success} title="Success" id="flash-success" flash={@flash} />
      <.flash kind={:info} title="Info" id="flash-info" flash={@flash} />
      <.flash
        id="flash-client-error"
        kind={:error}
        title="Unable to connect to the server"
        phx-disconnected={show(".phx-client-error #flash-client-error")}
        phx-connected={hide("#flash-client-error")}
        hidden
      >
        Attempting to reconnect... <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="flash-server-error"
        kind={:error}
        title="Lost connection to server"
        phx-disconnected={show(".phx-server-error #flash-server-error")}
        phx-connected={hide("#flash-server-error")}
        hidden
      >
        Attempting to reconnect... <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Renders a page footer.

  ## Example

      <.footer />
  """
  def footer(assigns) do
    ~H"""
    <div class="w-full">
      <%!-- limit max width of footer by nesting it inside a full-width element --%>
      <section class="max-w-[100rem] mx-auto bg-base-300 py-6 text-center 2xl:rounded-t-xl">
        <ul class="list-none">
          <li>
            <div class="text-xl font-bold">
              Quiz Game
            </div>
          </li>

          <%!-- project links --%>
          <li class="mt-6">
            <.link href={~p"/"}>
              Home
            </.link>
          </li>

          <%!-- extra links --%>
          <li class="mt-6">
            <.link href={~p"/terms-of-use"}>
              Terms of Use
            </.link>
          </li>
          <li class="mt-2">
            <.link href={~p"/privacy-policy"}>
              Privacy Policy
            </.link>
          </li>

          <%!-- legal stuff --%>
          <li class="mt-6">
            <small>
              &copy; Copyright <%= DateTime.utc_now().year %>. All rights reserved.
            </small>
          </li>
        </ul>
      </section>
    </div>
    """
  end

  @doc """
  Renders a form button.

  ## Examples

      <.form_button>Button Text</.form_button>
      <.form_button phx-click="go" class="ml-2">Button Text</.form_button>
  """
  attr :type, :string, default: "button"
  attr :class, :any, default: nil
  attr :content, :string, default: "", doc: "the button text (can use default slot instead)"
  attr :loader, :boolean, default: false, doc: "show a loading spinner"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the form button"

  slot :inner_block

  def form_button(assigns) do
    ~H"""
    <.button
      type={@type}
      class={[
        "form-button",
        @class
      ]}
      loader={@loader}
      {@rest}
    >
      <%= if @content != "" do %>
        <%= @content %>
      <% else %>
        <%= render_slot(@inner_block) %>
      <% end %>
    </.button>
    """
  end

  @doc """
  Renders a form submit button.

  ## Examples

      <.form_submit_button />Send!</.form_submit_button>
      <.form_submit_button phx-click="go" class="ml-2">Custom submit text</.form_submit_button>
  """
  attr :type, :string, default: "submit"
  attr :class, :any, default: nil
  attr :content, :string, default: "Submit"
  attr :loader, :boolean, default: true
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the form button"

  def form_button_submit(assigns) do
    ~H"""
    <.form_button
      type={@type}
      class={["btn-success", @class]}
      content={@content}
      loader={@loader}
      {@rest}
    />
    """
  end

  @doc """
  Renders a form cancel button.

  ## Examples

      <.form_submit_button />Send!</.form_submit_button>
      <.form_submit_button phx-click="go" class="ml-2">Custom submit text</.form_submit_button>
  """
  attr :type, :string, default: "button"
  attr :class, :any, default: nil
  attr :url, :string, default: nil, doc: "the URL to redirect to"
  attr :content, :string, default: "Cancel"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the form button"

  def form_button_cancel(assigns) do
    ~H"""
    <a href={@url} tabindex="-1">
      <.form_button
        type={@type}
        class={["btn-secondary", @class]}
        onclick={@url || "history.back()"}
        content={@content}
        {@rest}
      />
    </a>
    """
  end

  @doc """
  Renders an alert indicating that the form has errors.
  """
  def form_error_alert(assigns) do
    ~H"""
    <div class="alert alert-error shadow-xl" role="alert">
      To continue, fix the errors in the form.
    </div>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from your `assets/vendor/heroicons` directory and bundled
  within your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :debounce, :integer, default: 750, doc: "how long to debounce before emitting an event"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} data-component="input">
      <input
        type="hidden"
        name={@name}
        id={@id || @name}
        class={["hidden", @class]}
        value={@value}
        {@rest}
      />
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class={[
          "mt-1 block w-full py-2 px-3 border border-gray-300 bg-white sm:text-sm",
          "rounded-md shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-base-500"
        ]}
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "mt-2 block min-h-[6rem] w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "min-h-[6rem] phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        phx-debounce={@debounce}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        phx-debounce={@debounce}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-base-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a loading indicator.

  ## Example

      <.loader />
  """
  attr :class, :string, default: nil

  def loader(assigns) do
    ~H"""
    <icon
      name="hero-arrow-path"
      class={[
        "w-5 h-5 hidden phx-click-loading:inline phx-submit-loading:inline animate-spin",
        @class
      ]}
    />
    """
  end

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirm" on_confirm={JS.push("delete")} on_cancel={JS.navigate(~p"/posts")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}

  slot :inner_block, required: true
  slot :title
  slot :subtitle
  slot :confirm
  slot :cancel

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      class="relative z-50 hidden"
    >
      <div
        id={"#{@id}-bg"}
        class="fixed inset-0 bg-base-100/90 transition-opacity"
        aria-hidden="true"
      />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-2 sm:p-4 lg:py-4">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class={[
                "hidden max-w-[30rem] mx-auto relative rounded-2xl bg-base-100 p-8",
                "shadow-lg shadow-base-700/10 ring-1 ring-zinc-300/10 transition"
              ]}
            >
              <%!-- close button --%>
              <div class="absolute top-5 right-4">
                <button
                  phx-click={hide_modal(@on_cancel, @id)}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="h-5 w-5 stroke-current" />
                </button>
              </div>

              <div id={"#{@id}-content"}>
                <header :if={@title != []}>
                  <h1
                    id={"#{@id}-title"}
                    class="text-2xl font-semibold leading-8 text-base-800 text-center"
                  >
                    <%!-- title --%>
                    <%= render_slot(@title) %>
                  </h1>
                  <p
                    :if={@subtitle != []}
                    id={"#{@id}-description"}
                    class="mt-2 text-lg leading-6 text-base-600 text-center"
                  >
                    <%!-- subtitle --%>
                    <%= render_slot(@subtitle) %>
                  </p>
                </header>

                <section class="text-center">
                  <%= render_slot(@inner_block) %>
                </section>
                <div :if={@confirm != [] or @cancel != []} class="mt-8 text-center">
                  <.link
                    :for={cancel <- @cancel}
                    phx-click={hide_modal(@on_cancel, @id)}
                    class="w-[7rem] mx-2 btn btn-secondary"
                  >
                    <%= render_slot(cancel) %>
                  </.link>
                  <.button
                    :for={confirm <- @confirm}
                    class="w-[7rem] mx-2"
                    id={"#{@id}-confirm"}
                    phx-click={@on_confirm}
                    phx-disable-with
                  >
                    <%= render_slot(confirm) %>
                  </.button>
                </div>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders the primary navbar.

  ## Example

      <.navbar />
  """
  def navbar(assigns) do
    ~H"""
    <div class="w-full">
      <%!-- limit max width of navbar by nesting it inside a full-width element --%>
      <nav
        data-component="page-navbar"
        class="navbar max-w-[100rem] mx-auto bg-base-300 py-0 2xl:rounded-b-xl"
      >
        <%!-- navbar start items --%>
        <div class="flex-1">
          <%!-- navbar title --%>
          <.link navigate="/" class="text-2xl text-accent normal-case btn-ghost btn px-2">
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
            <ul class="w-52 p-2 shadow menu dropdown-content bg-base-100 n-transition-background
                       rounded-box border-2 border-secondary">
              <div class="mt-2 mb-3 text-center text-lg font-bold">
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
            <div class="modal" x-bind:class="show && 'modal-open'">
              <div
                class="relative max-w-xs modal-box border-2 overflow-x-hidden"
                x-show="show"
                x-transition.duration.500ms
                x-trap.inert.noscroll.noreturn="show"
                x-on:click.outside="show = false"
              >
                <h2 class="mb-12 text-3xl font-bold text-center">Settings</h2>
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
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-10 space-y-8">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="w-full mx-auto flex flex-center flex-wrap">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="w-[40rem] mt-11 sm:w-full">
        <thead class="text-sm text-left leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pr-6 pb-4 font-normal"><%= col[:label] %></th>
            <th class="relative p-0 pb-4"><span class="sr-only"><%= gettext("Actions") %></span></th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, @row_item.(row)) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, @row_item.(row)) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  # js commands
  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(QuizGameWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(QuizGameWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
