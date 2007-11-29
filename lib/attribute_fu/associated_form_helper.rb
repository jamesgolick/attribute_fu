module AttributeFu
  module AssociatedFormHelper
    def fields_for_associated(associated, *args, &block)
      associated_name = associated.class.name.underscore
      name            = associated_base_name associated_name
      conf            = args.last if args.last.is_a? Hash
      
      unless associated.new_record?
        name << "[#{associated.new_record? ? 'new' : associated.id}]"
      else
        @new_objects ||= {}
        @new_objects[associated_name] ||= -1 # we want naming to start at 0
        identifier = !conf.nil? && conf[:javascript] ? '#{number}' : @new_objects[associated_name]+=1
        
        name << "[new][#{identifier}]"
      end
      
      @template.fields_for(name, *args.unshift(associated), &block)
    end
    
    def remove_link(name, *args)
      options = args.extract_options!

      css_selector = options.delete(:selector) || ".#{@object.class.name.underscore}"
      function     = options.delete(:function) || ""
      
      function << "$(this).up(&quot;#{css_selector}&quot;).remove()"
      
      @template.link_to_function(name, function, *args.push(options))
    end
    
    def add_associated_link(name, object, opts = {})
      associated_name  = object.class.name.underscore
      variable         = "attribute_fu_#{associated_name}_count"
      
      opts.symbolize_keys!
      partial          = opts[:partial]   || associated_name
      container        = opts[:container] || associated_name.pluralize
      
      form_builder     = self # because the value of self changes in the block
      
      @template.link_to_function name do |page|
        page << "if (typeof #{variable} == 'undefined') #{variable} = 0;"
        page << "new Insertion.Bottom('#{container}', new Template("+render(:partial => "#{partial}", :locals => {associated_name.to_sym => object, :f => form_builder}).to_json+").evaluate({'number': --#{variable}}))"
      end
    end
    
    private
      def associated_base_name(associated_name)
        "#{@object_name}[#{associated_name}_attributes]"
      end
  end
end