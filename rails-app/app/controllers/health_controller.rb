require 'httparty'

class HealthController < ApplicationController
  def check
    render json: { status: 'Rails OK' }
  end

  def chain
    python_response = HTTParty.get("#{ENV['PYTHON_SERVICE_URL']}/chain")
    render json: {
      service: "rails",
      status: "OK",
      python_response: python_response.parsed_response
    }
  rescue => e
    render json: { 
      error: "Service chain failed",
      details: e.message
    }, status: :service_unavailable
  end
end

# require 'httparty'
# class HealthController < ApplicationController
#   def check
#     render json: 'Rails is working now'
#   end

#   def chain
#     begin
#       python_response = HTTParty.get('http://localhost:5000/chain')
      
#       render json: {
#         service: "rails",
#         status: "OK",
#         python_response: JSON.parse(python_response.body)
#       }
#     rescue StandardError => e
#       render json: { 
#         error: "Failed to connect to Python service",
#         details: e.message
#       }, status: :service_unavailable
#     end
#   end
#   # def chain
#   #   render json: {
#   #     service: "rails",
#   #     status: "OK",
#   #     message: "This is a test response before connecting to Python"
#   #   }
#   # end
# end
# # class HealthController < ApplicationController
# #   def check
# #   end
# # end
