defmodule QuizGameWeb.Support do
  @moduledoc """
  This project's helper functions.
  """

  @doc """
  A wrapper script that checks if a form's CAPTCHA has been completed, and is valid.
  """

  @spec form_captcha_valid?(map()) :: boolean()
  def form_captcha_valid?(params) do
    # only check for captcha if captcha enabled
    if Enum.member?([:error, {:ok, nil}, nil], Application.fetch_env(:hcaptcha, :public_key)) do
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
end
