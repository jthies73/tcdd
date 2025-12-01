class Participant < ApplicationRecord
  has_many :participations

  validates :name, presence: true, uniqueness: true

  scope :alphabetically, -> { order(name: :asc) }

  # sums up participant.people_count from all participants
  def self.total_people_count
    sum(:people_count)
  end
end
