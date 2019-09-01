module Exceptions
  class NoAttributesToUpdateError < StandardError
    def message
      "Without attributes to update!"
    end
  end
end
