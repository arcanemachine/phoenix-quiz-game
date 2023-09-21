defmodule QuizGameWeb.Support.HTMLTest do
  @moduledoc false
  use ExUnit.Case
  import QuizGameWeb.Support.HTML.Form, only: [captcha_valid?: 1]

  @test_site_key "10000000-ffff-ffff-ffff-000000000001"
  @test_secret_key "0x0000000000000000000000000000000000000000"

  @valid_form_params %{"h-captcha-response" => "10000000-aaaa-bbbb-cccc-000000000001"}
  @invalid_form_params %{"h-captcha-response" => "invalid_response"}

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
      assert captcha_valid?(@valid_form_params)
    end

    test "returns false if captcha is not valid" do
      refute captcha_valid?(@invalid_form_params)
    end

    test "returns true if captcha is not enabled" do
      # disable hcaptcha
      Application.put_env(:hcaptcha, :public_key, false)

      assert captcha_valid?(@valid_form_params)
    end
  end
end
