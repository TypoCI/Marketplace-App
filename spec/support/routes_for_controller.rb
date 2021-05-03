def routes_for_controller(controller)
  Rails.application.routes.routes.select do |route|
    route.defaults[:controller] == controller && route.name.present?
  end
end
