defmodule QuizGameWeb.Support do
  @moduledoc "This project's web-related helper functions."

  @doc """
    If a given query returns a record, then return it. Otherwise, raise an exception that returns
    a 404 response.

    ## Examples

      iex> get_record_or_404(query)
      %User{}

      iex> get_record_or_404(empty_query)
      ** (Ecto.NoResultsError)
  """
  def get_record_or_404(query) do
    if record = QuizGame.Repo.one!(query) do
      record
    else
      raise Ecto.NoResultsError, queryable: query
    end
  end

  @doc "A wrapper script that checks if a form's CAPTCHA has been completed, and is valid."
  @spec form_captcha_valid?(map()) :: boolean()
  def form_captcha_valid?(params) do
    # only check for captcha if captcha enabled
    if Application.get_env(:hcaptcha, :public_key) == false do
      # always return true if hcaptcha disabled
      true
    else
      # check if captcha string is present, then check if it is valid
      with false <- String.length(params["h-captcha-response"]) == 0,
           {:ok, _response} <- Hcaptcha.verify(params["h-captcha-response"]) do
        true
      else
        _ ->
          false
      end
    end
  end

  @doc "Convert URL params to a keyword list."
  @spec params_to_keyword_list(map()) :: keyword()
  def params_to_keyword_list(params) do
    params |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end
end

defmodule QuizGameWeb.Support.Atom do
  @moduledoc "This project's atom-related helper functions."

  def to_human_friendly_string(atom) do
    Atom.to_string(atom) |> String.replace("_", " ") |> String.capitalize()
  end
end
