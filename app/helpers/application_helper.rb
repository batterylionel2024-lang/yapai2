module ApplicationHelper
  def categories_for_kind(kind)
    Rails.cache.fetch("categories_for_kind_#{kind}", expires_in: 12.hours) do
      Category.visible.where(category_kind: kind, parent_id: nil).includes(children: { children: { children: { children: :children } } }).to_a
    end
  end

  def channel_path(kind, options = {})
    case kind.to_s
    when 'apple' then apple_channel_path(options)
    when 'huawei' then huawei_channel_path(options)
    when 'oppo' then oppo_channel_path(options)
    when 'vivo' then vivo_channel_path(options)
    when 'xiaomi' then xiaomi_channel_path(options)
    when 'custom' then custom_channel_path(options)
    else categories_path(options)
    end
  end
end
