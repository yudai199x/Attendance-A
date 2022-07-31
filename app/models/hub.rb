class Hub < ApplicationRecord
  validates :number, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :worked_type, presence: true, inclusion: { in: ['出勤', '退勤'] }
end
