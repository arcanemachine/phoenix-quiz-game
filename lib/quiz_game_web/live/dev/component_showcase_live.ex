defmodule QuizGameWeb.DevLive.ComponentShowcaseLive do
  use QuizGameWeb, :live_view

  @page_title "Component Showcase"

  # data
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

  # support
  defp _form_build_empty() do
    to_form(FormData.changeset(%FormData{}, %{}))
  end

  defp _form_has_errors?(form) do
    !Enum.empty?(form.errors)
  end

  defp _form_validate(params) do
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
  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       form: _form_build_empty(),
       form_has_errors: false,
       page_title: @page_title,
       table_rows: [
         %TableRow{id: 1, col1: "Value 1", col2: "Value 2"},
         %TableRow{id: 2, col1: "Value 3", col2: "Value 4"},
         %TableRow{id: 3, col1: "Value 5", col2: "Value 6"}
       ]
     )}
  end

  @impl true
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
    {:noreply, assign(socket, form: _form_build_empty())}
  end

  def handle_event("form-submit", %{"form_data" => form_data} = params, socket) do
    form = _form_validate(form_data)

    if Enum.empty?(form.errors) do
      if QuizGameWeb.Support.HTML.Form.captcha_valid?(params) do
        # captcha is valid
        {:noreply,
         socket
         |> push_event("toast-show-success", %{content: "Form submitted successfully"})
         |> push_event("captcha-reset", %{})
         |> assign(form: form, form_has_errors: _form_has_errors?(form))}
      else
        # captcha is not valid
        {:noreply,
         socket
         |> push_event("toast-show-error", %{
           content: "You must complete the human test at the bottom of the form."
         })
         |> assign(form: form, form_has_errors: _form_has_errors?(form))}
      end
    else
      {:noreply, assign(socket, form: form, form_has_errors: _form_has_errors?(form))}
    end
  end

  def handle_event("form-validate" = _event, %{"form_data" => form_data}, socket) do
    form = _form_validate(form_data)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("loader-demo", _params, socket) do
    Process.sleep(1000)
    {:noreply, socket}
  end
end
