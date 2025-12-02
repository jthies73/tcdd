class PageVisit < ApplicationRecord
  validates :visited_on, presence: true, uniqueness: true

  def self.track_visit!
    today = Date.current
    visit = find_or_initialize_by(visited_on: today)
    visit.count ||= 0
    visit.count += 1
    visit.save!
  end

  def self.today_count
    find_by(visited_on: Date.current)&.count || 0
  end

  def self.total_count
    sum(:count)
  end
end
