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

  class ProductNotFoundError < StandardError
    def message
      "Product not found!"
    end
  end

  class ListNotFoundError < StandardError
    def message
      "List not found!"
    end
  end

  class CategoryNotFoundError < StandardError
    def message
      "Category not found!"
    end
  end

  class ProductNotInListError < StandardError
    def message
      "Product not in List!"
    end
  end

  class ProductNotInCategoryError < StandardError
    def message
      "Product not in Category!"
    end
  end

  class ProductAlreadyInListError < StandardError
    def message
      "Product already in List!"
    end
  end

  class ProductAlreadyInCategoryError < StandardError
    def message
      "Product already in Category!"
    end
  end

  class PaginatedObjectsNotFound < StandardError
    attr_reader :object_name

    def initialize(object_name = "Objects")
      @object_name = object_name
    end

    def message
      "No #{@object_name} registries found for this page !"
    end
  end
end
