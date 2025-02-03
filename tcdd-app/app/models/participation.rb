class Participation < ApplicationRecord
  belongs_to :clean_up

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: %w[registered participating returned] }
end
