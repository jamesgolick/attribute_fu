module AttributeFu
  module Associations
    
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        class_inheritable_accessor  :managed_child_attributes
        write_inheritable_attribute :managed_child_attributes, []
      end
    end
    
    def method_missing(method_name, *args)
      if method_name.to_s =~ /.+?\_attributes=/
        association_name = method_name.to_s.gsub '_attributes=', ''
        association      = managed_child_attributes.detect { |element| element == association_name.to_sym } || managed_child_attributes.detect { |element| element == association_name.pluralize.to_sym }
        
        unless association.nil?
          has_many_attributes association, args.first
          
          return
        end
      end
      
      super
    end
    
    private
      def has_many_attributes(association_id, attributes)
        association = send(association_id)

        attributes.symbolize_keys!
        attributes.delete(:new).each    { |index, new_attrs| association.create new_attrs } if attributes.has_key?(:new)
        attributes.delete(:remove).each { |id| association.delete association.detect { |associated| associated.id == id.to_i }  } if attributes.has_key?(:remove)
        
        attributes.stringify_keys!
        attributes.each do |id, object_attrs|
          object = association.detect { |associated| associated.id.to_s == id }
          object.update_attributes object_attrs unless object.nil?
        end
      end
    
    module ClassMethods
      def has_many(association_id, options = {}, &extension)
        unless (config = options.delete(:attributes)).nil?
          self.managed_child_attributes << association_id
        end
        
        super
      end
    end
    
  end # Associations
end # AttributeFu
