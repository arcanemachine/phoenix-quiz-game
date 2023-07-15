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

  def handle_event("flash-error-show", _params, socket) do
    {:noreply, socket |> put_flash(:error, "Error flash message")}
  end

  def handle_event("flash-info-show", _params, socket) do
    {:noreply, socket |> put_flash(:info, "Info flash message")}
  end

  def handle_event("form-reset", _params, socket) do
    {:noreply, assign(socket, form: build_empty_form())}
  end

  def handle_event("form-submit", params, socket) do
    handle_event("form-validate", params, socket)
  end

  def handle_event("form-validate" = _event, %{"form_data" => form_data_params}, socket) do
    form =
      %FormData{}
      |> FormData.changeset(form_data_params)
      |> Ecto.Changeset.validate_required(Map.keys(FormData.types()))
      |> Ecto.Changeset.add_error(:text, "Error message")
      |> Ecto.Changeset.add_error(:email, "Error message")
      |> Ecto.Changeset.add_error(:checkbox, "Error message")
      |> Ecto.Changeset.add_error(:select, "Error message")
      |> Ecto.Changeset.add_error(:textarea, "Error message")
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def render(assigns) do
    ~H"""
    <h2 class="text-3xl mb-4 text-center">Button</h2>

    <section class="text-center">
      <div>
        <.button class="w-32 m-1 btn-primary">
          Primary
        </.button>
        <.button class="w-32 m-1 btn-secondary">
          Secondary
        </.button>
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
        <.button class="w-32 m-1 btn-warning">
          Warning
        </.button>
        <.button class="w-32 m-1 btn-error">
          Error
        </.button>
      </div>
    </section>

    <h2 class="mt-16 mb-4 text-3xl text-center">Modal</h2>

    <.modal id="showcase-modal" on_confirm={hide_modal("showcase-modal")}>
      <:title>Modal Title</:title>
      <:subtitle>Modal Subtitle</:subtitle>
      <div class="my-8">
        Modal content
      </div>
      <:confirm>OK</:confirm>
      <:cancel>Cancel</:cancel>
    </.modal>

    <section class="text-center">
      <.button phx-click={show_modal("showcase-modal")}>
        Show Modal
      </.button>
    </section>

    <h2 class="mt-16 mb-4 text-3xl text-center">Flash</h2>

    <section class="text-center">
      <.button class="w-40 m-1 btn-info" phx-click="flash-info-show">
        Info Flash
      </.button>
      <.button class="w-40 m-1 btn-error" phx-click="flash-error-show">
        Error Flash
      </.button>
    </section>

    <h2 class="mt-16 text-3xl text-center">Simple Form</h2>

    <.simple_form
      class="max-w-lg mx-auto"
      for={@form}
      autocomplete="off"
      phx-change="form-validate"
      phx-submit="form-submit"
    >
      <%!-- fields --%>
      <.input field={@form[:text]} label="Text Input" />
      <.input field={@form[:email]} label="Email Input" />
      <.input field={@form[:password]} type="password" label="Password Input" />

      <div class="form-control">
        <.input
          type="checkbox"
          field={@form[:checkbox]}
          class="checkbox checkbox-primary"
          label="Checkbox Input"
        />
      </div>

      <div class="form-control">
        <.input
          field={@form[:select]}
          type="select"
          options={[
            [key: "Select an option", value: "", disabled: true],
            [key: "First", value: "first"],
            [key: "Second", value: "second"],
            [key: "Third", value: "third"]
          ]}
          label="Select Input"
        />
      </div>

      <div class="form-control">
        <.label for="form_data_textarea">
          Textarea Label
        </.label>
        <.input
          type="textarea"
          field={@form[:textarea]}
          checked={true}
          class="checkbox checkbox-primary"
        />
      </div>

      <%!-- actions --%>
      <:actions>
        <.form_button_cancel url={~p"/"} />
        <.form_button class="btn-warning" phx-click="form-reset">Reset</.form_button>
        <.form_button_submit />
      </:actions>
    </.simple_form>

    <h2 class="mt-16 mb-4 text-3xl text-center">Header</h2>

    <.header class="bg-info/30 p-4 rounded-lg">
      Header Title
      <:subtitle>
        Header subtitle
      </:subtitle>
      <:actions>
        <.button class="w-28 btn-primary">OK</.button>
      </:actions>
    </.header>

    <h2 class="mt-16 mb-4 text-3xl text-center">Table</h2>

    <.table id="showcase-table" rows={@table_rows}>
      <:col :let={row} label="Column 1"><%= row.col1 %></:col>
      <:col :let={row} label="Column 2"><%= row.col2 %></:col>
    </.table>

    <h2 class="mt-16 mb-4 text-3xl text-center">List</h2>
    <h4 class="text-md mb-4 text-center">Renders a data list.</h4>

    <.list>
      <:item title="Item 1">Value 1</:item>
      <:item title="Item 2">Value 2</:item>
      <:item title="Item 3">Value 3</:item>
    </.list>

    <h2 class="mt-16 mb-4 text-3xl text-center">Back</h2>
    <h4 class="text-md mb-4 text-center">Renders a back navigation link.</h4>

    <.back navigate={~p"/"}>
      Back
    </.back>

    <h2 class="mt-16 mb-4 text-3xl text-center">Show/Hide</h2>

    <section class="text-center">
      <.button phx-click={show("#showcase-show-hide")}>Show</.button>
      <.button phx-click={hide("#showcase-show-hide")}>Hide</.button>

      <p class="mt-2">
        <span id="showcase-show-hide">Now you see me...</span>
      </p>
    </section>
    """
  end
end
