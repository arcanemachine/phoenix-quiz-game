defmodule QuizGameWeb.Dev.Live.ComponentShowcase do
  @moduledoc false
  use QuizGameWeb, :live_view

  # data
  defmodule FormData do
    @moduledoc false

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
    @moduledoc false
    defstruct id: 0, col1: "Value 1", col2: "Value 2"
  end

  # support
  defp form_build_empty() do
    to_form(FormData.changeset(%FormData{}, %{}))
  end

  defp form_has_errors?(form) do
    !Enum.empty?(form.errors)
  end

  defp form_validate(params) do
    %FormData{}
    |> FormData.changeset(params)
    # |> Ecto.Changeset.validate_required(Map.keys(FormData.types()))
    |> Ecto.Changeset.validate_required([:textarea])
    |> Ecto.Changeset.validate_format(:textarea, ~r/^pass$/, message: "should be 'pass'")
    # |> Ecto.Changeset.validate_acceptance(:checkbox, message: "should be checked")
    |> Map.put(:action, :validate)
    |> to_form()
  end

  # lifecycle
  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       form: form_build_empty(),
       form_has_errors: false,
       page_title: "Component Showcase",
       table_rows: [
         %TableRow{id: 1, col1: "Value 1", col2: "Value 2"},
         %TableRow{id: 2, col1: "Value 3", col2: "Value 4"},
         %TableRow{id: 3, col1: "Value 5", col2: "Value 6"}
       ]
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("flash-show-info", _params, socket) do
    {:noreply, socket |> put_flash(:info, "Info flash message")}
  end

  def handle_event("flash-show-success", _params, socket) do
    {:noreply, socket |> put_flash(:success, "Success flash message")}
  end

  def handle_event("flash-show-warning", _params, socket) do
    {:noreply, socket |> put_flash(:warning, "Warning flash message")}
  end

  def handle_event("flash-show-error", _params, socket) do
    {:noreply, socket |> put_flash(:error, "Error flash message")}
  end

  def handle_event("flash-show-long", _params, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       "This is a really long flash message. I mean, really, it's quite long. " <>
         "It's so long that the text shouldn't fit on a single line."
     )}
  end

  def handle_event("form-reset", _params, socket) do
    {:noreply, assign(socket, form: form_build_empty())}
  end

  def handle_event("form-submit", %{"form_data" => form_data} = params, socket) do
    form = form_validate(form_data)

    if Enum.empty?(form.errors) do
      if QuizGameWeb.Support.HTML.Form.captcha_valid?(params) do
        # captcha is valid
        {:noreply,
         socket
         |> push_event("toast-show-success", %{content: "Form submitted successfully"})
         |> push_event("captcha-reset", %{})
         |> assign(form: form, form_has_errors: form_has_errors?(form))}
      else
        # captcha is not valid
        {:noreply,
         socket
         |> push_event("toast-show-error", %{
           content: "You must complete the human test at the bottom of the form."
         })
         |> assign(form: form, form_has_errors: form_has_errors?(form))}
      end
    else
      {:noreply, assign(socket, form: form, form_has_errors: form_has_errors?(form))}
    end
  end

  def handle_event("form-validate" = _event, %{"form_data" => form_data}, socket) do
    form = form_validate(form_data)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("loader-demo", _params, socket) do
    Process.sleep(1000)
    {:noreply, socket}
  end

  def handle_event("reactivity-demo-handle-click", _params, socket) do
    {:noreply,
     socket |> assign(reactivity_demo_count: (socket.assigns[:reactivity_demo_count] || 0) + 1)}
  end
end
