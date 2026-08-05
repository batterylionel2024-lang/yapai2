class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  validates :name, :country, :phone, :email, presence: true

  def self.statuses
    { 'pending' => 'pending', 'replied' => 'replied' }
  end

  def pending?
    status == 'pending'
  end

  def replied?
    status == 'replied'
  end
end
