class Location < ApplicationRecord
  validates :address, presence: true
  validates :city, presence: true, uniqueness: true
  validates :latitude, presence: true
  validates :longitude, presence: true
end
