class ApplicationController < Jets::Controller::Base
  include Response
  include Exceptions
  include ExceptionHandler
end
