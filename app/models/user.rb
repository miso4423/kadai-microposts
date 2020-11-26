class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
    uniqueness: { case_senseitive: false }
    
  has_secure_password
  
  has_many :microposts
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  has_many :favorites
  has_many :favorite_microposts, through: :favorites, source: :micropost
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  def favorite(micropost)
    favorites.find_or_create_by(micropost_id: micropost.id)
  end
  
  def unfavorite(micropost)
    favorite = favorites.find_by(micropost_id: micropost.id)
    favorite.destroy if favorite
  end
  
  def favorites?(micropost)
    self.favorite_microposts.include?(micropost)
  end
end

# undefined local variable or method `user1' for main:Object
# user1 = User.find(1)
# micropost3 = Micropost.find(3)
# user1.favorite(micropost3)
# user1.favorite_microposts

#2.5.3 :008 > user1.favorte(micropost3)
# Traceback (most recent call last):
#         1: from (irb):8
# NoMethodError (undefined method `favorte' for #<User:0x0000000004e7bec8>)
# Did you mean?  favorite
#               favorites

# 2.5.3 :011 > user1.favorite_microposts
# Traceback (most recent call last):
#         1: from (irb):11
# NoMethodError (undefined method `favorite_microposts' for #<User:0x0000000004011d10>)
# Did you mean?  favorite_ids

# 2.5.3 :002 > user1.favorite_microposts
# Traceback (most recent call last):
#         1: from (irb):2
# ActiveRecord::HasManyThroughSourceAssociationNotFoundError (Could not find the source association(s)
# "favorite_micropost" or :favorite_microposts in model Favorite. 
# Try 'has_many :favorite_microposts, :through => :favorites, :source => <name>'. Is it one of user or micropost?)

# 2.5.3 :002 > user1.favorite_microposts
#   Micropost Load (1.5ms)  SELECT  `microposts`.* FROM `microposts` INNER JOIN `favorites` ON `microposts`.`id` = `favorites`.`micropost_id` WHERE `favorites`.`user_id` = 1 LIMIT 11
# => #<ActiveRecord::Associations::CollectionProxy [#<Micropost id: 3, content: "おはようございます", user_id: 2, created_at: "2020-11-07 06:55:16", updated_at: "2020-11-07 06:55:16"