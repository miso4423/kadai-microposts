class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :micropost
  validates_uniqueness_of :micropost_id, scope: :user_id
end
