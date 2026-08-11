class Category < ApplicationRecord
  has_many :children, -> { unscoped.order(:position, :id) }, class_name: "Category", foreign_key: :parent_id, dependent: :destroy
  belongs_to :parent, class_name: "Category", optional: true
  has_many :skus, dependent: :destroy
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [300, 300], format: :webp, saver: { quality: 80 }
    attachable.variant :featured, resize_to_limit: [600, 800], format: :webp, saver: { quality: 85 }
  end

  default_scope { order(:position, :id) }

  validates :name, presence: true
  validates :keywords, length: { maximum: 255 }
  before_validation :generate_slug, if: -> { slug.blank? }
  validates :category_kind, presence: true, inclusion: { in: %w[apple huawei oppo vivo xiaomi samsung transsion custom] }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "只能包含小写字母、数字和连字符" }
  
  scope :visible, -> { where(hidden: false) }

  after_commit :clear_cache

  def to_param
    slug.presence || id.to_s
  end
  validate :leaf_category_constraint_for_parent
  validate :consistent_category_kind

  def leaf?
    children.empty?
  end

  def depth
    parent ? parent.depth + 1 : 0
  end

  def all_descendant_skus
    if leaf?
      skus.order(position: :asc, created_at: :desc)
    else
      Sku.where(category_id: all_descendant_ids + [ id ]).order(position: :asc, created_at: :desc)
    end
  end

  def all_descendant_ids
    # Fetch all visible categories once and group them by parent_id to avoid N+1 queries
    all_visible = Category.unscoped.visible.select(:id, :parent_id).to_a
    children_map = all_visible.group_by(&:parent_id)
    
    desc_ids = []
    stack = children_map[id] || []
    
    while stack.any?
      child = stack.pop
      desc_ids << child.id
      stack.concat(children_map[child.id] || [])
    end
    desc_ids
  end

  def ancestors_and_self
    res = [ self ]
    node = self
    while node.parent
      node = node.parent
      res.unshift(node)
    end
    res
  end

  def localized_name
    case I18n.locale.to_sym
    when :en
      name
    when :"zh-CN", :zh
      name_zh.presence || name
    else
      name_zh.presence || name
    end
  end

  private

  def generate_slug
    return if name.blank?
    self.slug = name.parameterize
  end

  def clear_cache
    %w[apple huawei oppo vivo xiaomi samsung transsion custom].each do |kind|
      Rails.cache.delete("categories_for_kind_#{kind}")
    end
  end

  def leaf_category_constraint_for_parent
    return if parent_id.nil?

    if parent.skus.exists?
      errors.add(:parent_id, "该父分类下已有 SKU，无法在此添加子分类。")
    end
  end

  def consistent_category_kind
    if parent && category_kind != parent.category_kind
      errors.add(:category_kind, "必须与父分类的频道一致")
    end
  end
end
