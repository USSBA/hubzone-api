# Provides a route for the AWS health check
class HealthCheckController < ApplicationController
  def status
    render plain: "I'm OK"
  end
end
