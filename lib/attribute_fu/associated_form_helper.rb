module AttributeFu
  module AssociatedFormHelper
    def fields_for_associated(associated_name, *args, &block)
      object = args.first
      name   = "#{@object_name}[#{associated_name}_attributes]"

      unless object.new_record?
        name << "[#{object.new_record? ? 'new' : object.id}]"
      else
        @new_objects ||= {}
        @new_objects[associated_name] ||= -1 # we want naming to start at 0
        
        name << "[new][#{@new_objects[associated_name]+=1}]"
      end
      
      @template.fields_for(name, *args, &block)
    end
  end
end