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
  
  context "with javascript flag" do
    setup do
      _erbout = ''
      fields_for(:photo) do |f|
        _erbout.concat(f.fields_for_associated(:comment, @photo.comments.build, :javascript => true) do |comment|
          comment.text_field(:author)
        end)
      end
      
      @erbout = _erbout
    end
    
    should "use placeholders instead of numbers" do
      assert_match 'photo[comment_attributes][new][#{number}]', @erbout
    end
  end
  
  context "add_associated_link " do
    setup do
      comment = @photo.comments.build
      
      _erbout = ''
      fields_for(:photo) do |f|
        nil.stubs(:render).with(:partial => "comment", :locals => {:comment => comment, :f => f}) # which object am I really supposed to mock here????
        _erbout.concat f.add_associated_link("Add Comment", comment)
      end
      
      @erbout = _erbout
    end

    should "create link" do
      assert_match ">Add Comment</a>", @erbout
    end
    
    should "insert into the bottom of the parent container by default" do
      assert_match "Insertion.Bottom('comments'", @erbout
    end
    
    should "wrap the partial in a prototype template" do
      assert_match "new Template", @erbout
      assert_match "evaluate", @erbout
    end
    
    should "name the variable correctly" do
      assert_match "attribute_fu_comment_count", @erbout
    end
    
    should "produce the following link" do
      # this is a way of testing the whole link
      assert_equal %{
        <a href=\"#\" onclick=\"if (typeof attribute_fu_comment_count == 'undefined') attribute_fu_comment_count = 0;\nnew Insertion.Bottom('comments', new Template(null).evaluate({'number': --attribute_fu_comment_count})); return false;\">Add Comment</a>
      }.strip, @erbout
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
