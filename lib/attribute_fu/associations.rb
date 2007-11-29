module AttributeFu
  module Associations
    
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        class_inheritable_accessor  :managed_association_attributes
        write_inheritable_attribute :managed_association_attributes, []
        
        after_update :save_managed_associations
      end
    end
    
    def method_missing(method_name, *args)
      if method_name.to_s =~ /.+?\_attributes=/
        association_name = method_name.to_s.gsub '_attributes=', ''
        association      = managed_association_attributes.detect { |element| element == association_name.to_sym } || managed_association_attributes.detect { |element| element == association_name.pluralize.to_sym }
        
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
        attributes = {} unless attributes.is_a? Hash

        attributes.symbolize_keys!
        
        if attributes.has_key?(:new)
          new_attrs = attributes.delete(:new)
          new_attrs = new_attrs.sort do |a,b|
            value = lambda { |i| i < 0 ? i.abs + new_attrs.length : i }
            
            value.call(a.first.to_i) <=> value.call(b.first.to_i)
          end
          new_attrs.each { |i, new_attrs| association.build new_attrs } 
        end
        
        attributes.stringify_keys!        
        instance_variable_set removal_variable_name(association_id), association.reject { |object| object.new_record? || attributes.has_key?(object.id.to_s) }.map(&:id)
        attributes.each do |id, object_attrs|
          object = association.detect { |associated| associated.id.to_s == id }
          object.attributes = object_attrs unless object.nil?
        end
      end
      
      def save_managed_associations
        managed_association_attributes.each do |association_id|
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
          self.managed_association_attributes << association_id
        end
        
        super
      end
    end
    
  end # Associations
end # AttributeFu
