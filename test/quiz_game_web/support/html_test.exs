defmodule QuizGameWeb.Support.HTMLTest do
  @moduledoc false
  use ExUnit.Case
  doctest QuizGameWeb.Support.HTML
end

defmodule QuizGameWeb.Support.HTML.FormTest do
  @moduledoc false
  use ExUnit.Case
  alias QuizGameWeb.Support.HTML.Form
  doctest QuizGameWeb.Support.HTML.Form

  @test_site_key "10000000-ffff-ffff-ffff-000000000001"
  @test_secret_key "0x0000000000000000000000000000000000000000"

  @valid_form_params %{"h-captcha-response" => "10000000-aaaa-bbbb-cccc-000000000001"}
  @invalid_form_params %{"h-captcha-response" => "invalid_response"}

  @tag network: true
  describe "captcha_valid?/1" do
    setup do
      # set temporary values for hcaptcha environment variables so that the captcha will work
      Application.put_env(:hcaptcha, :public_key, @test_site_key)
      Application.put_env(:hcaptcha, :secret, @test_secret_key)

      on_exit(fn ->
        Application.put_env(:hcaptcha, :public_key, false)
        Application.put_env(:hcaptcha, :secret, false)
      end)
    end

    test "returns true if captcha is valid" do
      assert Form.captcha_valid?(@valid_form_params)
    end

    test "returns false if captcha is not valid" do
      refute Form.captcha_valid?(@invalid_form_params)
    end

    test "returns true if captcha is not enabled" do
      # disable hcaptcha
      Application.put_env(:hcaptcha, :public_key, false)

      assert Form.captcha_valid?(@valid_form_params)
    end
  end
end
