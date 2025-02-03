class CleanUp < ApplicationRecord
  has_many :participations, dependent: :destroy
end
