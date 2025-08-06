module Api
  module V1
    class BaseController < ApplicationController
      include ErrorHandler
      include Pagination
    end
  end
end
