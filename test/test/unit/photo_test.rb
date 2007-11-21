require File.dirname(__FILE__) + '/../test_helper'

class PhotoTest < ActiveSupport::TestCase
  should_have_many :comments
  
  context "comment_attributes" do
    setup do
      @photo = Photo.create
      @gob = @photo.comments.create :author => "Gob Bluth",  :body => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed..."
      @bob = @photo.comments.create :author => "Bob Loblaw", :body => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed..."
      
      @photo.comment_attributes = { @gob.id.to_s => { :author => "Buster Bluth", :body => "I said it was _our_ nausia..." },
                                    :new         => { "0" => { :author => "George-Michael", :body => "I was going to smoke the marijuana like a ciggarette." }},   
                                    :remove      => [@bob.id.to_s]}
      @photo.save
    end
    
    context "with existing child" do
      setup do
        @gob.reload
      end

      should "update attributes" do
        assert_equal "Buster Bluth", @gob.author, "Author attribute of child model was not updated."
        assert_equal "I said it was _our_ nausia...", @gob.body, "Body attribute of child model was not updated."
      end
    end
    
    context "with new hash" do
      should "create new comment" do
        assert @photo.comments.any? { |comment| comment.author == "George-Michael" && comment.body =~ /was going to smoke/i }, "New comment was not created."
      end
    end
    
    context "with remove hash" do
      should "remove those children from the parent" do
        assert !@photo.comments.any? { |comment| comment.author == "Bob Loblaw" }, "Comment in remove array was not removed."
      end
    end
  end
end
