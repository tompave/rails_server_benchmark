Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  controller :benchmarks do
    get "/fibonacci/:number", action: :fibonacci

    get "/template-render",             action: :template_render
    get "/template-render-no-response", action: :template_render_no_response

    get "/network-io",            action: :network_io
    get "/network-io-and-render", action: :network_io_and_render

    get "/pause/:seconds",            action: :pause    
    get "/pause-and-render/:seconds", action: :pause_and_render
  end
end
