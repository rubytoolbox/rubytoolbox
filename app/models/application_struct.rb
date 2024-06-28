# frozen_string_literal: true

#
# Base class for dry-struct value objects
#
class ApplicationStruct < Dry::Struct
  transform_keys(&:to_sym)
end
