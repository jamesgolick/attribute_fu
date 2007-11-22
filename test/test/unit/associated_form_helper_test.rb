require File.dirname(__FILE__)+'/../test_helper'

class AssociatedFormHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include AttributeFu::AssociatedFormHelper
    
  def setup
    @photo   = Photo.create
    @controller = mock()
    @controller.stubs(:url_for).returns 'asdf'
    @controller.stubs(:protect_against_forgery?).returns false
    stubs(:protect_against_forgery?).returns false
  end
    
  context "with existing object" do
    setup do
      @photo.comments.create :author => "Barry", :body => "Oooh I did good today..."
      
      @erbout = assoc_output @photo.comments.first
    end
    
    should "name field with attribute_fu naming conventions" do
      assert_match "photo[comment_attributes][#{@photo.comments.first.id}]", @erbout
    end
  end
  
  context "with non-existent object" do
    setup do      
      @erbout = assoc_output(@photo.comments.build) do |f|
        f.fields_for_associated(:comment, @photo.comments.build) do |comment|
          comment.text_field(:author)
        end
      end
    end
    
    should "name field with attribute_fu naming conventions" do
      assert_match "photo[comment_attributes][new][0]", @erbout
    end

    should "maintain the numbering of the new object if called again" do
        assert_match "photo[comment_attributes][new][1]", @erbout
    end
  end
  
  private
    def assoc_output(comment, &block)
      _erbout = ''
      fields_for(:photo) do |f|
        f.fields_for_associated(:comment, comment) do |comment|
          _erbout.concat comment.text_field(:author)
        end
        
        _erbout.concat yield(f) if block_given?
      end
      
      _erbout
    end
end
