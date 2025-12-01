class Participant < ApplicationRecord
  has_many :participations

  validates :name, presence: true, uniqueness: true

  scope :alphabetically, -> { order(name: :asc) }
end
