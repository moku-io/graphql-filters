require_relative 'filters/version'
require_relative 'filters/utility/cached_class'

module Graphql
  module Filters
    # This will one day be a separate gem, and in that moment we will change this reference accordingly
    CachedClass = Utility::CachedClass
    private_constant :CachedClass
  end
end
