defmodule QuizGameWeb.Base.ComponentShowcaseLive do
  use QuizGameWeb, :live_view

  defmodule FormData do
    @types %{
      text: :string,
      email: :string,
      password: :string,
      checkbox: :boolean,
      select: :string,
      textarea: :string
    }

    defstruct text: "",
              email: "",
              password: "",
              checkbox: false,
              select: "",
              textarea: ""

    def changeset(%__MODULE__{} = form_data, attrs) do
      {form_data, @types} |> Ecto.Changeset.cast(attrs, Map.keys(@types))
    end

    def types, do: @types
  end

  defmodule TableRow do
    defstruct id: 0, col1: "Value 1", col2: "Value 2"
  end

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       form: build_empty_form(),
       page_title: "Component Showcase",
       table_rows: [
         %TableRow{id: 1, col1: "Value 1", col2: "Value 2"},
         %TableRow{id: 2, col1: "Value 3", col2: "Value 4"},
         %TableRow{id: 3, col1: "Value 5", col2: "Value 6"}
       ]
     )}
  end

  defp build_empty_form() do
    to_form(FormData.changeset(%FormData{}, %{}))
  end

  def handle_event("flash-info-show", _params, socket) do
    {:noreply, socket |> put_flash(:info, "Info flash message")}
  end

  def handle_event("flash-success-show", _params, socket) do
    {:noreply, socket |> put_flash(:success, "Success flash message")}
  end

  def handle_event("flash-warning-show", _params, socket) do
    {:noreply, socket |> put_flash(:warning, "Warning flash message")}
  end

  def handle_event("flash-error-show", _params, socket) do
    {:noreply, socket |> put_flash(:error, "Error flash message")}
  end

  def handle_event("flash-long-show", _params, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       "This is a really long flash message. I mean, really, it's quite long. " <>
         "It's so long that the text shouldn't fit on a single line."
     )}
  end

  def handle_event("form-reset", _params, socket) do
    {:noreply, assign(socket, form: build_empty_form())}
  end

  def handle_event("form-submit", params, socket) do
    handle_event("form-validate", params, socket)
  end

  def handle_event("loader-demo", _params, socket) do
    Process.sleep(1000)
    {:noreply, socket}
  end

  def handle_event("form-validate" = _event, %{"form_data" => form_data_params}, socket) do
    form =
      %FormData{}
      |> FormData.changeset(form_data_params)
      |> Ecto.Changeset.validate_required(Map.keys(FormData.types()))
      |> Ecto.Changeset.validate_inclusion(:text, ["pass"], message: "Must be 'pass'")
      |> Ecto.Changeset.validate_inclusion(
        :email,
        ["pass@example.com"],
        message: "Must be 'pass@example.com'"
      )
      |> Ecto.Changeset.validate_format(:password, ~r/pass/, message: "Must be 'pass'")
      |> Ecto.Changeset.validate_acceptance(:checkbox, message: "Must be checked")
      |> Ecto.Changeset.validate_inclusion(:select, ["pass"], message: "Must be 'pass'")
      |> Ecto.Changeset.validate_inclusion(:textarea, ["pass"], message: "Must be 'pass'")
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def render(assigns) do
    ~H"""
    <h2 class="mb-8 text-3xl text-center">Built-In Components</h2>

    <h3 class="mb-4 text-2xl text-center">Back</h3>

    <div class="text-center">
      <.back navigate={~p"/"}>
        Back
      </.back>
    </div>

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">Button</h3>

    <section class="flex justify-center flex-wrap gap-1">
      <div>
        <.button class="w-32 m-1 btn-primary">
          Primary
        </.button>
        <.button class="w-32 m-1 btn-secondary">
          Secondary
        </.button>
      </div>
      <div>
        <.button class="w-32 m-1 btn-accent">
          Accent
        </.button>
        <.button class="w-32 m-1 btn-neutral">
          Neutral
        </.button>
      </div>
      <div>
        <.button class="w-32 m-1 btn-info">
          Info
        </.button>
        <.button class="w-32 m-1 btn-success">
          Success
        </.button>
      </div>
      <div>
        <.button class="w-32 m-1 btn-warning">
          Warning
        </.button>
        <.button class="w-32 m-1 btn-error">
          Error
        </.button>
      </div>
    </section>

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">Error</h3>

    <div class="flex flex-center">
      <.error>Error message</.error>
    </div>

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">Flash Messages</h3>

    <section class="text-center">
      <div>
        <.button class="w-40 m-1 btn-info" phx-click="flash-info-show">
          Info Flash
        </.button>
        <.button class="w-40 m-1 btn-success" phx-click="flash-success-show">
          Success Flash
        </.button>
      </div>
      <div>
        <.button class="w-40 m-1 btn-warning" phx-click="flash-warning-show">
          Warning Flash
        </.button>
        <.button class="w-40 m-1 btn-error" phx-click="flash-error-show">
          Error Flash
        </.button>
      </div>
      <div>
        <.button class="w-40 m-1" phx-click="flash-long-show">
          Long Flash
        </.button>
      </div>
    </section>

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">Header</h3>

    <.header class="m-2 bg-info text-info-content">
      Header Title
    </.header>

    <.header class="m-2 bg-success text-success-content">
      Header Title
      <:subtitle>
        Header subtitle
      </:subtitle>
    </.header>

    <.header id="header-warning" class="m-2 bg-warning text-warning-content">
      Header Title
      <:subtitle>
        Header subtitle
      </:subtitle>
      <:actions>
        <.button class="w-28 btn-primary border-primary-content" phx-click={hide("#header-warning")}>
          Hide me
        </.button>
      </:actions>
    </.header>

    <.header class="m-2 bg-error text-error-content">
      Header Title
      <:subtitle>
        Header subtitle
      </:subtitle>
      <:actions>
        <.button class="w-28 btn-secondary border-success-content">Action 1</.button>
        <.button class="w-28 btn-primary border-primary-content">Action 2</.button>
      </:actions>
    </.header>

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">List</h3>

    <.list>
      <:item title="Item 1">Value 1</:item>
      <:item title="Item 2">Value 2</:item>
      <:item title="Item 3">Value 3</:item>
    </.list>

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">Modal</h3>

    <section class="text-center">
      <.button phx-click={show_modal("component-showcase-modal")}>
        Show Modal
      </.button>
    </section>

    <.modal id="component-showcase-modal" on_confirm={hide_modal("component-showcase-modal")}>
      <:title>Modal Title</:title>
      <:subtitle>Modal Subtitle</:subtitle>
      <div class="my-8">
        Modal content
      </div>
      <:confirm>OK</:confirm>
      <:cancel>Cancel</:cancel>
    </.modal>

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">Show/Hide</h3>

    <section class="text-center">
      <.button phx-click={show("#showcase-show-hide")}>Show</.button>
      <.button phx-click={hide("#showcase-show-hide")}>Hide</.button>

      <p class="mt-2">
        <span id="showcase-show-hide">Now you see me...</span>
      </p>
    </section>

    <div class="my-8 divider" />

    <h3 class="text-2xl text-center">Simple Form</h3>

    <.simple_form
      for={@form}
      confirmation_required={true}
      autocomplete="off"
      phx-change="form-validate"
      phx-submit="form-submit"
    >
      <%= if @form.source.action && !@form.source.valid? do %>
        <.alert_form_errors />
      <% end %>
      <%= if @form.source.action && @form.source.valid? do %>
        <div class="text-xl text-success font-bold text-center">Form is valid</div>
      <% end %>

      <%!-- fields --%>
      <.input field={@form[:text]} label="Text input" value="pass" />
      <.input field={@form[:email]} label="Email input" value="pass@example.com" />
      <.input field={@form[:password]} type="password" label="Password input" value="pass" />

      <div class="form-control">
        <.input
          type="checkbox"
          field={@form[:checkbox]}
          class="checkbox"
          label="Checkbox input"
          checked
        />
      </div>

      <div class="form-control">
        <.input
          field={@form[:select]}
          type="select"
          options={[
            [key: "Select an option", value: "", disabled: true],
            [key: "pass", value: "pass"],
            [key: "fail", value: "fail"]
          ]}
          label="Select input"
          value="pass"
          phx-debounce="blur"
        />
      </div>

      <div class="form-control">
        <.input
          type="textarea"
          field={@form[:textarea]}
          label="Textarea input"
          class="textarea"
          value="pass"
        />
      </div>

      <%!-- actions --%>
      <:actions>
        <.form_button_cancel url={~p"/"} />
        <.form_button content="Reset" class="btn-warning" phx-click="form-reset" />
        <.form_button_submit />
      </:actions>
    </.simple_form>

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">Table</h3>

    <.table id="showcase-table" rows={@table_rows}>
      <:col :let={row} label="Column 1"><%= row.col1 %></:col>
      <:col :let={row} label="Column 2"><%= row.col2 %></:col>
    </.table>

    <div class="my-8 divider" />

    <h2 class="mb-8 text-3xl text-center">Custom Components</h2>

    <h3 class="mb-4 text-2xl text-center">Action Links</h3>

    <.action_links items={[
      %{content: "Item 1", navigate: "/dev/component-showcase"},
      %{content: "Item 2", navigate: "/dev/component-showcase", class: "italic"},
      %{content: "Item 3", navigate: "/dev/component-showcase", class: "underline"}
    ]} />

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">Loader</h3>

    <div class="text-center">
      <form phx-submit="loader-demo">
        <.button class="w-40" loader={true}>
          Loader Demo
        </.button>
      </form>
    </div>

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">Toast Messages</h3>

    <section x-data class="text-center">
      <div class="mb-4 text-lg font-italic" x-show="!$store.toasts">
        <code>Alpine.store('toasts')</code> does not exist, so this section will not be functional.
      </div>
      <div>
        <button
          class="w-40 m-1 btn btn-info"
          x-on:click="$store.toasts.showInfo('Info toast message example')"
        >
          Info Toast
        </button>
        <button
          class="w-40 m-1 btn btn-success"
          x-on:click="$store.toasts.showSuccess('Success toast message example')"
        >
          Success Toast
        </button>
      </div>
      <div>
        <button
          class="w-40 m-1 btn btn-warning"
          x-on:click="$store.toasts.showWarning('Warning toast message example')"
        >
          Warning Toast
        </button>
        <button
          class="w-40 m-1 btn btn-error"
          x-on:click="$store.toasts.showError('Error toast message example')"
        >
          Error Toast
        </button>
      </div>
      <div>
        <button
          class="w-40 btn m-1"
          x-on:click="$store.toasts.show('This is a really long toast message. I mean, really, it\'s quite long. It\'s so long that the text shouldn\'t fit on a single line.')"
        >
          Long Toast
        </button>
      </div>
    </section>
    """
  end
end
