class Customer < ApplicationRecord
  # Validaciones
  validates :name, presence: true
  validates :address, presence: true
end
