module SanitizeAttributes
  module InstanceMethods

    def write_attribute(*args)
      attr_name = args[0].to_sym
      value = args[1]
      if self.class.sanitizable_attributes.include?(attr_name)
        args[1] = process_text_via_sanitization_method(value, attr_name)
      end
      super(*args)
    end

    private
      def process_text_via_sanitization_method(txt, attr_name = nil)
        return nil if txt.nil?
        sanitization_method =  self.class.sanitization_method_for_attribute(attr_name) || # attribute level
             self.class.default_sanitization_method_for_class || # class level
             SanitizeAttributes::default_sanitization_method     # global
        if sanitization_method && sanitization_method.is_a?(Proc)
          sanitization_method.call(txt)
        else
          raise SanitizeAttributes::NoSanitizationMethodDefined
        end
      end
  end
end
