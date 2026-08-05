namespace :setup_products do
  desc "Clear categories/SKUs and seed 3 categories with 9 yapai products"
  task run: :environment do
    puts "Purging existing SKU images..."
    Sku.find_each do |sku|
      sku.images.purge
    end

    puts "Destroying SKUs and Categories..."
    Sku.destroy_all
    Category.destroy_all

    puts "Creating categories..."

    cat_a = Category.create!(
      name: "Baseball Yapais",
      name_zh: "棒球帽",
      category_kind: "a",
      parent_id: nil,
      hidden: false
    )

    cat_b = Category.create!(
      name: "Fashion Yapais",
      name_zh: "时尚帽",
      category_kind: "b",
      parent_id: nil,
      hidden: false
    )

    cat_c = Category.create!(
      name: "Winter Yapais",
      name_zh: "冬季帽",
      category_kind: "c",
      parent_id: nil,
      hidden: false
    )

    puts "Creating SKUs..."

    products = [
      { name: "Baseball Yapai",           name_zh: "棒球帽",     category: cat_a, img: "product_baseball_yapai.png",    position: 10 },
      { name: "Flat Bill Yapai",          name_zh: "平沿帽",     category: cat_a, img: "product_flat_bill_yapai.png",   position: 9 },
      { name: "Quick Dry Baseball Yapai", name_zh: "速干棒球帽", category: cat_a, img: "product_quick_dry_yapai.png",   position: 8 },
      { name: "Trucker Yapai",            name_zh: "卡车帽",     category: cat_a, img: "product_trucker_yapai.png",     position: 7 },
      { name: "Bucket Yapai",             name_zh: "渔夫帽",     category: cat_b, img: "product_bucket_yapai.png",      position: 10 },
      { name: "Visor Yapai",              name_zh: "遮阳帽",     category: cat_b, img: "product_visor_yapai.png",       position: 9 },
      { name: "Kids Yapai",               name_zh: "儿童帽",     category: cat_b, img: "product_kids_yapai.png",        position: 8 },
      { name: "Knit Beanie Yapai",        name_zh: "针织毛线帽", category: cat_c, img: "product_knit_beanie_yapai.png", position: 10 },
      { name: "Winter Yapais",            name_zh: "冬季帽",     category: cat_c, img: "product_winter_yapais.png",     position: 9 }
    ]

    products.each do |p|
      sku = Sku.create!(
        category: p[:category],
        name: p[:name],
        product_name: p[:name],
        status: "active",
        position: p[:position],
        moq: "100 pcs",
        sample_time: "7 days",
        production_lead_time: "30-45 days"
      )

      img_path = Rails.root.join("app", "assets", "images", p[:img])
      if File.exist?(img_path)
        sku.images.attach(
          io: File.open(img_path),
          filename: p[:img],
          content_type: "image/png"
        )
        puts "  ✓ #{p[:name]} — image attached"
      else
        puts "  ✗ #{p[:name]} — image NOT found at #{img_path}"
      end
    end

    puts "\nDone! Categories: #{Category.count}, SKUs: #{Sku.count}"
  end
end
