class Photo < ActiveRecord::Base
  has_many :comments
end
