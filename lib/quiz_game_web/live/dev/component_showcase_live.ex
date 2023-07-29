defmodule QuizGameWeb.Base.ComponentShowcaseLive do
  use QuizGameWeb, :live_view

  @page_title "Component Showcase"

  defmodule FormData do
    @types %{
      text: :string,
      email: :string,
      password: :string,
      checkbox: :boolean,
      select: :string,
      textarea: :string,
      captcha: :string
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
       form_has_errors: false,
       page_title: @page_title,
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

  def handle_event("form-submit", %{"form_data" => form_data} = params, socket) do
    form = validate_form(form_data)

    if Enum.empty?(form.errors) do
      if QuizGameWeb.Support.form_captcha_valid?(params) do
        {:noreply,
         socket
         |> push_event("toast-show-success", %{content: "Form submitted successfully"})
         |> assign(form: form, form_has_errors: form_has_errors?(form))}
      else
        {:noreply,
         socket
         |> push_event("toast-show-error", %{
           content: "Please check the box that says 'I am human'."
         })
         |> assign(form: form, form_has_errors: form_has_errors?(form))}
      end
    else
      {:noreply, assign(socket, form: form, form_has_errors: form_has_errors?(form))}
    end
  end

  def handle_event("loader-demo", _params, socket) do
    Process.sleep(1000)
    {:noreply, socket}
  end

  def handle_event("form-validate" = _event, %{"form_data" => form_data}, socket) do
    form = validate_form(form_data)

    {:noreply, assign(socket, form: form, form_has_errors: form_has_errors?(form))}
  end

  defp validate_form(params) do
    %FormData{}
    |> FormData.changeset(params)
    # |> Ecto.Changeset.validate_required(Map.keys(FormData.types()))
    |> Ecto.Changeset.validate_required([:textarea])
    |> Ecto.Changeset.validate_format(:textarea, ~r/^pass$/, message: "should be 'pass'")
    # |> Ecto.Changeset.validate_acceptance(:checkbox, message: "should be checked")
    |> Map.put(:action, :validate)
    |> to_form()
  end

  defp form_has_errors?(form) do
    !Enum.empty?(form.errors)
  end

  def render(assigns) do
    ~H"""
    <h2 class="mb-8 text-3xl text-center">Built-In Components</h2>

    <h2 class="mb-8 text-3xl text-center">Alert</h2>

    <section class="[&>*]:mb-4">
      <.alert kind="primary">Primary alert</.alert>
      <.alert kind="secondary">Secondary alert</.alert>
      <.alert kind="accent">Accent alert</.alert>
      <.alert kind="neutral">Neutral alert</.alert>
      <.alert kind="info">Info alert</.alert>
      <.alert kind="success">Success alert</.alert>
      <.alert kind="warning">Warning alert</.alert>
      <.alert kind="error">Error alert</.alert>
    </section>

    <div class="my-8 divider" />

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
        <.button kind="primary" class="w-32 m-1">
          Primary
        </.button>
        <.button kind="secondary" class="w-32 m-1">
          Secondary
        </.button>
      </div>
      <div>
        <.button kind="accent" class="w-32 m-1">
          Accent
        </.button>
        <.button kind="neutral" class="w-32 m-1">
          Neutral
        </.button>
      </div>
      <div>
        <.button kind="info" class="w-32 m-1">
          Info
        </.button>
        <.button kind="success" class="w-32 m-1">
          Success
        </.button>
      </div>
      <div>
        <.button kind="warning" class="w-32 m-1">
          Warning
        </.button>
        <.button kind="error" class="w-32 m-1">
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
        <.button kind="info" class="w-40 m-1" phx-click="flash-info-show">
          Info Flash
        </.button>
        <.button kind="success" class="w-40 m-1" phx-click="flash-success-show">
          Success Flash
        </.button>
      </div>
      <div>
        <.button kind="warning" class="w-40 m-1" phx-click="flash-warning-show">
          Warning Flash
        </.button>
        <.button kind="error" class="w-40 m-1" phx-click="flash-error-show">
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
        <.button class="w-28" phx-click={hide("#header-warning")}>
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
        <.button kind="secondary" class="w-28">Action 1</.button>
        <.button kind="primary" class="w-28">Action 2</.button>
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
      has_errors={@form_has_errors}
      confirmation_required={true}
      autocomplete="off"
      phx-change="form-validate"
      phx-submit="form-submit"
    >
      <%= if !@form.source.action do %>
        <.alert kind="secondary">The form has not been completed.</.alert>
      <% end %>
      <%= if @form.source.action && !@form.source.valid? do %>
        <.alert_form_errors />
      <% end %>
      <%= if @form.source.action && @form.source.valid? do %>
        <.alert kind="success">The form is valid.</.alert>
      <% end %>

      <%!-- fields --%>
      <.input field={@form[:text]} label="Text input" />
      <.input field={@form[:email]} label="Email input" />
      <.input field={@form[:password]} type="password" label="Password input" />

      <div class="form-control">
        <.input type="checkbox" field={@form[:checkbox]} class="checkbox" label="Checkbox input" />
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
          phx-debounce="blur"
        />
      </div>

      <div id="deleteme">&nbsp;</div>
      <script>
        setTimeout(() => { document.querySelector('#deleteme').scrollIntoView(); }, 100)
      </script>

      <div class="form-control">
        <.input type="textarea" field={@form[:textarea]} label="Textarea input" class="textarea" />
      </div>

      <.input type="captcha" />

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

    <.action_links>
      <.action_links_item>
        <.link navigate="/dev/component-showcase">
          Item 1
        </.link>
      </.action_links_item>
      <.action_links_item kind="back" class="ml-4">
        <.link navigate="/dev/component-showcase">
          Item 2
        </.link>
      </.action_links_item>
      <.action_links_item>
        <.link navigate="/dev/component-showcase" class="italic">
          Item 3
        </.link>
      </.action_links_item>
      <.action_links_spacer />
      <.action_links_item>
        <.link navigate="/dev/component-showcase">
          Item below <code>&lt;.action_links_spacer&gt;</code>
        </.link>
      </.action_links_item>
    </.action_links>

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

    <h3 class="mb-4 text-2xl text-center">Simple Form Actions Default</h3>

    <div class="text-center">
      <.simple_form for={%{}}>
        <:actions>
          <.simple_form_actions_default />
        </:actions>
      </.simple_form>
    </div>

    <div class="my-8 divider" />

    <h3 class="mb-4 text-2xl text-center">Toast Messages</h3>

    <section x-data class="text-center">
      <div class="mb-4 text-lg font-italic" x-show="!$store.toasts">
        Alpine.js is not installed, or <code>Alpine.store('toasts')</code>
        does not exist, so this section will not be functional.
      </div>
      <div>
        <.button
          kind="primary"
          class="w-48 m-1"
          x-on:click="$store.toasts.show('primary', 'Primary toast message example')"
        >
          Primary Toast
        </.button>
        <.button
          kind="secondary"
          class="w-48 m-1"
          x-on:click="$store.toasts.show('secondary', 'Secondary toast message example')"
        >
          Secondary Toast
        </.button>
      </div>
      <div>
        <.button
          kind="accent"
          class="w-48 m-1"
          x-on:click="$store.toasts.show('accent', 'Accent toast message example')"
        >
          Accent Toast
        </.button>
        <.button
          kind="neutral"
          class="w-48 m-1"
          x-on:click="$store.toasts.show('neutral', 'Neutral toast message example')"
        >
          Neutral Toast
        </.button>
      </div>
      <div>
        <.button
          kind="info"
          class="w-48 m-1"
          x-on:click="$store.toasts.show('info', 'Info toast message example')"
        >
          Info Toast
        </.button>
        <.button
          kind="success"
          class="w-48 m-1"
          x-on:click="$store.toasts.show('success', 'Success toast message example')"
        >
          Success Toast
        </.button>
      </div>
      <div>
        <.button
          kind="warning"
          class="w-48 m-1"
          x-on:click="$store.toasts.show('warning', 'Warning toast message example')"
        >
          Warning Toast
        </.button>
        <.button
          kind="error"
          class="w-48 m-1"
          x-on:click="$store.toasts.show('error', 'Error toast message example')"
        >
          Error Toast
        </.button>
      </div>
      <div>
        <.button
          class="w-48 btn m-1"
          x-on:click="$store.toasts.show('primary', 'This is a really long toast message. I mean, really, it\'s quite long. It\'s so long that the text shouldn\'t fit on a single line.')"
        >
          Long Toast
        </.button>
        <.button class="w-48 btn m-1" x-on:click="$store.toasts.clear">
          Clear Toasts
        </.button>
      </div>
    </section>
    """
  end
end
