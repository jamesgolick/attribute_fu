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
    
  context "fields for associated" do
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
  end
  
  context "remove link" do
    context "with just a name" do
      setup do
        remove_link "remove"
      end

      should "create a link" do
        assert_match ">remove</a>", @erbout
      end

      should "infer the name of the current @object in fields_for" do
        assert_match "$(this).up(&quot;.comment&quot;).remove()", @erbout
      end
    end
    
    context "with an alternate CSS selector" do
      setup do
        remove_link "remove", :selector => '.blah'
      end

      should "use the alternate selector" do
        assert_match "$(this).up(&quot;.blah&quot;).remove()", @erbout
      end
    end
    
    context "with an extra function" do
      setup do
        @other_function = "$('asdf').blah();"
        remove_link "remove", :function => @other_function
      end

      should "still infer the name of the current @object in fields_for, and create the function as usual" do
        assert_match "$(this).up(&quot;.comment&quot;).remove()", @erbout
      end
      
      should "append the secondary function" do
        assert_match @other_function, @erbout
      end
    end
  end
  
  context "ensure_submission_of_associated" do
    setup do
      @erbout = assoc_output(@photo.comments.build) do |f|
        f.ensure_submission_of_associated(:comment, @photo.comments.build)
      end
    end

    should "create hidden field" do
      assert_match 'type="hidden"', @erbout
    end
    
    should "set value to blank" do
      assert_match 'value=""', @erbout
    end
    
    should "be named with convention" do
      assert_match 'name="photo[comment_attributes]"', @erbout
    end
  end
  
  private
    def assoc_output(comment, &block)
      _erbout = ''
      fields_for(:photo) do |f|
        _erbout.concat(f.fields_for_associated(:comment, comment) do |comment|
          comment.text_field(:author)
        end)
        
        _erbout.concat yield(f) if block_given?
      end
      
      _erbout
    end
    
    def remove_link(*args)
      @erbout = assoc_output(@photo.comments.build) do |f|
        f.fields_for_associated(:comment, @photo.comments.build) do |comment|
          comment.remove_link *args
        end
      end
    end
end
