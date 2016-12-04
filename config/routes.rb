Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  controller :benchmarks do
    get "/noop",              action: :noop
    get "/pause/:seconds",    action: :pause
    get "/network-io",        action: :network_io
    get "/file-io",           action: :file_io
    get "/fibonacci/:number", action: :fibonacci
    get "/template",          action: :template
    get "/mix-and-match",     action: :mix_and_match
  end
end
