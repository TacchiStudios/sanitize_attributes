module SanitizeAttributes
  module Macros
    # sanitize_attributes is used to define sanitizable attributes within a model definition.
    def sanitize_attributes(*args, &block)
      unless @sanitize_hook_already_defined
        include InstanceMethods
        extend ClassMethods

        cattr_accessor :sanitizable_attribute_hash
        cattr_accessor :sanitization_block_array
        self.sanitizable_attribute_hash ||= {}
        self.sanitization_block_array ||= []

        @sanitize_hook_already_defined = true
      end

      if block
        self.sanitization_block_array << block
        block = self.sanitization_block_array.index(block)
      else
        block = nil
      end

      args.each do |attr|
        self.sanitizable_attribute_hash[attr] = block

        class_eval <<-EOM, __FILE__, __LINE__ + 1
          def #{attr}
            val = read_attribute('#{attr}')
            val = val.html_safe unless val.nil?
            val
          end
        EOM
      end

      true
    end
  end
end
