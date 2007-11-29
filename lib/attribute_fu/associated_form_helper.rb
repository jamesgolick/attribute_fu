module AttributeFu
  module AssociatedFormHelper
    def fields_for_associated(associated_name, *args, &block)
      object = args.first
      name   = associated_base_name associated_name
      conf   = args.last if args.last.is_a? Hash
      
      unless object.new_record?
        name << "[#{object.new_record? ? 'new' : object.id}]"
      else
        @new_objects ||= {}
        @new_objects[associated_name] ||= -1 # we want naming to start at 0
        identifier = !conf.nil? && conf[:javascript] ? '#{number}' : @new_objects[associated_name]+=1
        
        name << "[new][#{identifier}]"
      end
      
      @template.fields_for(name, *args, &block)
    end
    
    def remove_link(name, *args)
      options = args.extract_options!

      css_selector = options.delete(:selector) || ".#{@object.class.name.underscore}"
      function     = options.delete(:function) || ""
      
      function << "$(this).up(&quot;#{css_selector}&quot;).remove()"
      
      @template.link_to_function(name, function, *args.push(options))
    end
    
    def add_associated_link(name, object)
      associated_name  = object.class.name.underscore
      container        = associated_name.pluralize
      variable         = "attribute_fu_#{associated_name}_count"
      form_builder     = self # because the value of self changes in the block
      
      @template.link_to_function name do |page|
        page << "if (typeof #{variable} == 'undefined') #{variable} = 0;"
        page << "new Insertion.Bottom('#{container}', new Template("+render(:partial => "#{associated_name}", :locals => {associated_name.to_sym => object, :f => form_builder}).to_json+").evaluate({'number': --#{variable}}))"
      end
    end
    
    private
      def associated_base_name(associated_name)
        "#{@object_name}[#{associated_name}_attributes]"
      end
  end
end