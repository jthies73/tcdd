class Participant < ApplicationRecord
  has_many :participations

  validates :name, presence: true, uniqueness: true

  default_scope { order(name: :asc) }
end
