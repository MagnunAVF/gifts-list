module Exceptions
  class NoAttributesToUpdateError < StandardError
    def message
      "Without attributes to update!"
    end
  end

  class ClientNotFoundError < StandardError
    def message
      "Client not found!"
    end
  end

  class ParentCategoryNotFoundError < StandardError
    def message
      "Parent Category not found!"
    end
  end
end
