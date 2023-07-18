defmodule QuizGameWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component, global_prefixes: ~w(x-)
  use QuizGameWeb, :verified_routes

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
      <div class="text-2xl font-bold">
        <%= @title || "Actions" %>
      </div>
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

  attr :kind, :string,
    required: true,
    values: ~w(primary secondary accent neutral info success warning error)

  attr :class, :string, default: nil

  slot :inner_block, required: true

  @doc """
  Renders an alert message.

  ## Examples

      <.alert kind="info">
        This is an alert message.
      </.alert>

  """
  def alert(assigns) do
    ~H"""
    <div class={[
      "max-w-lg mx-auto mb-8 alert alert-#{@kind} bg-#{@kind} text-#{@kind}-content",
      @class
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders an alert indicating that the form has errors.

  ## Examples

      <.alert_form_errors />

  """
  def alert_form_errors(assigns) do
    ~H"""
    <.alert kind="error">
      To continue, fix the errors in the form.
    </.alert>
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
    <div class="mt-12">
      <.link navigate={@navigate}>
        <.icon name="hero-arrow-left-solid" class="h-4 w-4" /><%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button kind="success" class="ml-2" phx-click="go">Send!</.button>
  """
  attr :type, :string, default: nil

  attr :kind, :string,
    default: "primary",
    values: ~w(primary secondary accent neutral info success warning error)

  attr :class, :any, default: nil
  attr :loader, :boolean, default: false
  attr :rest, :global, default: %{loader: false}

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button type={@type} class={["btn btn-#{@kind}", @class]} {@rest}>
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
    <p class="flex items-center gap-3 text-sm font-semibold text-error phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="h-5 w-5 flex-none" />
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
        "w-80 sm:w-[25rem] mt-2 mx-auto p-3 z-50 rounded-lg ring-1",
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
        <div>
          <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-7 w-7" />
          <.icon :if={@kind == :success} name="hero-check-circle-mini" class="h-7 w-7" />
          <.icon :if={@kind == :warning} name="hero-exclamation-circle-mini" class="h-7 w-7" />
          <.icon :if={@kind == :error} name="hero-exclamation-triangle-mini" class="h-7 w-7" />
        </div>
        <p class="grow px-4 text-sm font-semibold cursor-default select-none">
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
    <div class="fixed w-screen top-6 right-0 left-0 mt-child-2">
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
  Renders a form button.

  ## Examples

      <.form_button>Button Text</.form_button>
      <.form_button phx-click="go" class="ml-2">Button Text</.form_button>
  """
  attr :type, :string, default: "button"
  attr :content, :string, default: "", doc: "the button text (can use default slot instead)"
  attr :class, :any, default: nil
  attr :loader, :boolean, default: false, doc: "show a loading spinner"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the form button"

  slot :inner_block

  def form_button(assigns) do
    ~H"""
    <.button type={@type} class={["form-button", @class]} loader={@loader} {@rest}>
      <%= @content %>
    </.button>
    """
  end

  @doc """
  Renders a form cancel button.

  ## Examples

      <.form_button_cancel />
      <.form_button_cancel url={~p"/"} />
  """
  attr :type, :string, default: "button"
  attr :content, :string, default: "Cancel"
  attr :class, :any, default: nil
  attr :url, :string, default: nil, doc: "the URL to redirect to"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the form button"

  def form_button_cancel(assigns) do
    ~H"""
    <a href={@url} tabindex="-1">
      <.form_button
        type={@type}
        content={@content}
        class={["btn-secondary", @class]}
        onclick={(@url && "location.href = '#{@url}'") || "history.back()"}
        {@rest}
      />
    </a>
    """
  end

  @doc """
  Renders a form submit button.

  ## Examples

      <.form_submit_button />Send!</.form_submit_button>
      <.form_submit_button phx-click="go" class="ml-2">Custom submit text</.form_submit_button>
  """
  attr :type, :string, default: "submit"
  attr :content, :string, default: "Submit"
  attr :class, :any, default: nil
  attr :loader, :boolean, default: true
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the form button"

  def form_button_submit(assigns) do
    ~H"""
    <.form_button
      type={@type}
      content={@content}
      class={["flex btn-success", @class]}
      loader={@loader}
      {@rest}
    />
    """
  end

  @doc """
  Renders a header with title.

  ## Examples

    <.header id="your-header" class="bg-info text-info-content">
      Header Title
      <:subtitle>
        Header subtitle
      </:subtitle>
      <:actions>
        <.button class="w-28 btn-primary border-primary-content">Action</.button>
      </:actions>
    </.header>

  """
  attr :id, :string, default: nil
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header
      id={@id}
      class={[
        "flex items-center justify-stretch gap-6 p-4 rounded-lg",
        @class
      ]}
    >
      <div class="grow">
        <div class="text-lg font-semibold leading-8">
          <%= render_slot(@inner_block) %>
        </div>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex justify-end flex-col sm:flex-row flex-wrap gap-2">
        <%= render_slot(@actions) %>
      </div>
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

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} data-component="input">
      <input type="hidden" name={@name} id={@id || @name} class="hidden" value={@value} {@rest} />
    </div>
    """
  end

  def input(%{type: "checkbox", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div class="mt-4" phx-feedback-for={@name}>
      <label class="flex items-center gap-2 cursor-pointer">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={[
            "checkbox",
            @errors == [] && "border-base-content focus:border-base-content/30",
            @errors != [] && "border-error/80 focus:border-error/40",
            "phx-no-feedback:border-base-content phx-no-feedback:focus:border-base-content/40"
          ]}
          {@rest}
        />
        <%= @label %>
      </label>
      <div class="flex min-h-[2.5rem] show-empty-element">
        <.error :for={msg <- @errors}>
          <%= msg %>
        </.error>
      </div>
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
          "w-full select select-bordered",
          @errors == [] && "border-base-content focus:border-base-content/30",
          @errors != [] && "border-error/80 focus:border-error/40",
          "phx-no-feedback:border-base-content phx-no-feedback:focus:border-base-content/40"
        ]}
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <div class="flex min-h-[2.5rem] show-empty-element">
        <.error :for={msg <- @errors}><%= msg %></.error>
      </div>
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
          "min-h-[6rem] w-full textarea textarea-bordered",
          @errors == [] && "border-base-content focus:border-base-content/30",
          @errors != [] && "border-error/80 focus:border-error/40",
          "phx-no-feedback:border-base-content phx-no-feedback:focus:border-base-content/40"
        ]}
        phx-debounce={@debounce}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <div class="flex min-h-[2.5rem] show-empty-element">
        <.error :for={msg <- @errors}><%= msg %></.error>
      </div>
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
          "w-full input",
          @errors == [] && "border-base-content focus:border-base-content/30",
          @errors != [] && "border-error/80 focus:border-error/40",
          "phx-no-feedback:border-base-content phx-no-feedback:focus:border-base-content/40"
        ]}
        phx-debounce={@debounce}
        {@rest}
      />
      <div class="flex min-h-[2.5rem] show-empty-element">
        <.error :for={msg <- @errors}><%= msg %></.error>
      </div>
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
    <label for={@for} class="label">
      <span class="label-text font-semibold">
        <%= render_slot(@inner_block) %>
      </span>
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
      <dl class="-my-4 divide-y divide-base-content">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-base-content font-bold"><%= item.title %></dt>
          <dd class="text-base-content"><%= render_slot(item) %></dd>
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
    <.icon
      name="hero-arrow-path"
      class="hidden phx-click-loading:inline phx-submit-loading:inline animate-spin"
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
      class="relative z-40 hidden"
    >
      <div
        id={"#{@id}-bg"}
        class="fixed inset-0 bg-base-100/80 transition-opacity"
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
                "shadow-lg shadow-base-content/20 ring-1 ring-base-content/40 transition"
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
                  <div id={"#{@id}-title"} class="text-2xl font-semibold leading-8 text-center">
                    <%!-- title --%>
                    <%= render_slot(@title) %>
                  </div>
                  <p
                    :if={@subtitle != []}
                    id={"#{@id}-description"}
                    class="mt-2 text-lg leading-6 text-center"
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
                    class="w-[7rem] mx-2 btn-primary"
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
  attr :confirmation_required, :boolean, default: false

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div
        class="max-w-lg mt-8 mx-auto"
        data-confirmation-required={@confirmation_required}
        x-data="simpleForm"
      >
        <%= render_slot(@inner_block, f) %>

        <%= if @confirmation_required do %>
          <label>
            <.header class="mt-4 mb-4 p-4 bg-primary text-primary-content cursor-pointer rounded-lg">
              <span class="text-sm font-normal">
                I have confirmed that the data above is accurate.
              </span>
              <:actions>
                <input
                  type="checkbox"
                  class="align-middle checkbox checkbox-lg border-none"
                  required
                  phx-debounce="999999"
                />
              </:actions>
            </.header>
          </label>
        <% end %>

        <div :for={action <- @actions} class="flex flex-center flex-wrap w-full mx-auto">
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
        <thead class="text-sm text-left leading-6 text-base-content">
          <tr>
            <th :for={col <- @col} class="p-0 pr-6 pb-4 font-normal"><%= col[:label] %></th>
            <th class="relative p-0 pb-4"><span class="sr-only"><%= gettext("Actions") %></span></th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-base-content border-t border-base-content text-sm
                 leading-6 text-base-content"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-slate-400">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 mr-6">
                <span class="absolute -z-10 -inset-y-px right-0 -left-4 group-hover:bg-slate-400" />
                <span class={["relative", i == 0 && "font-semibold text-base-content"]}>
                  <%= render_slot(col, @row_item.(row)) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-slate-400" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-base-content
                         hover:text-base-content/60"
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
      time: 300,
      transition:
        {"transition-all transform ease-in-out duration-300",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-in-out duration-300",
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
