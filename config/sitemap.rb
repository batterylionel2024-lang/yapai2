# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://yapaibattery.com'
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do
  # 首页和 sitemap 索引文件会自动添加

  # 静态页面
  add factory_path, priority: 0.7, changefreq: 'daily'
  add contact_path, priority: 0.5, changefreq: 'monthly'
  add products_path, priority: 0.8, changefreq: 'daily'

  # 分类页面
  Category.visible.find_each do |category|
    add category_path(category), lastmod: category.updated_at, priority: 0.7, changefreq: 'weekly'
  end

  # SKU 详情页面
  Sku.find_each do |sku|
    add sku_path(sku), lastmod: sku.updated_at, priority: 0.6, changefreq: 'weekly'
  end

  # 频道页面 (apple, huawei, oppo, vivo, xiaomi, custom)
  %w[apple huawei oppo vivo xiaomi custom].each do |kind|
    add send("#{kind}_channel_path"), priority: 0.7, changefreq: 'daily'
  end
end
