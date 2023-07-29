defmodule QuizGameWeb.Support do
  @moduledoc """
  This project's helper functions.
  """

  @doc """
  A wrapper script that checks if a form's CAPTCHA has been completed, and is valid.
  """
  def form_captcha_valid?(params) do
    with false <- String.length(params["h-captcha-response"]) == 0,
         {:ok, _response} <- Hcaptcha.verify(params["h-captcha-response"]) do
      true
    else
      _ ->
        false
    end
  end
end
