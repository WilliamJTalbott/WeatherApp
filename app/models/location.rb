class Location < ApplicationRecord
  validates :address, presence: true
  validates :city, presence: true, uniqueness: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  validate :geocoding_successful

  private

  def geocoding_successful
    if address.present? && latitude.nil?
      errors.add(:address, "could not be found")
    end
  end
end
