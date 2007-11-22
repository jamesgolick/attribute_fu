module AttributeFu
  module Associations
    
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        class_inheritable_accessor  :managed_child_attributes
        write_inheritable_attribute :managed_child_attributes, []
        
        after_update :save_managed_children
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
        attributes.delete(:new).each { |index, new_attrs| association.build new_attrs } if attributes.has_key?(:new)
        
        attributes.stringify_keys!        
        instance_variable_set removal_variable_name(association_id), association.reject { |object| object.new_record? || attributes.has_key?(object.id.to_s) }.map(&:id)
        attributes.each do |id, object_attrs|
          object = association.detect { |associated| associated.id.to_s == id }
          object.attributes = object_attrs unless object.nil?
        end
      end
      
      def save_managed_children
        managed_child_attributes.each do |association_id|
          association = send(association_id)
          association.each(&:save)
          
          unless (objects_to_remove = instance_variable_get removal_variable_name(association_id)).nil?
            objects_to_remove.each { |remove_id| association.delete association.detect { |obj| obj.id.to_s == remove_id.to_s } }
            instance_variable_set removal_variable_name(association_id), nil
          end
        end
      end
      
      def removal_variable_name(association_id)
        "@#{association_id.to_s.pluralize}_to_remove"
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
