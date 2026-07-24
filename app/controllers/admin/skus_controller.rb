class Admin::SkusController < Admin::BaseController
  before_action :set_sku, only: [:show, :edit, :update, :destroy, :delete_image]

  def index
    @q = params[:q]
    @category_id = params[:category_id]
    session[:sku_list_category_id] = @category_id

    @skus = Sku.all.includes(category: :parent, images_attachments: :blob).order(position: :asc, created_at: :desc)

    if @q.present?
      @skus = @skus.where("LOWER(name) LIKE ?", "%#{@q.downcase}%")
    end

    if @category_id.present?
      @skus = @skus.where(category_id: @category_id)
    end

    @categories = Category.joins(:skus).distinct.order(:name)

    respond_to do |format|
      format.html
      format.csv do
        unless current_user.super_admin?
          return redirect_to admin_skus_path, alert: "只有大管理员才能导出 CSV。"
        end
        @export_skus = @skus
        send_data generate_csv(@export_skus), filename: "skus-#{Date.today}.csv"
      end
    end
  end

  def export
    unless current_user.super_admin?
      return redirect_to admin_skus_path, alert: "只有大管理员才能导出 CSV。"
    end
    @skus = Sku.includes(category: :parent, images_attachments: :blob).order(position: :asc, created_at: :desc)
    send_data generate_csv(@skus), filename: "all-skus-#{Date.today}.csv"
  end


  def update_positions
    unless params[:positions].present?
      return redirect_back fallback_location: admin_skus_path, alert: "未提供有效的排序数据。"
    end

    positions = params[:positions].to_unsafe_h
                                  .transform_keys { |k| Integer(k) rescue nil }
                                  .transform_values { |v| Integer(v) rescue nil }
                                  .reject { |k, v| k.nil? || v.nil? || v < 0 || v > 999_999 }

    positions.each do |sku_id, position|
      Sku.where(id: sku_id).update_all(position: position)
    end

    redirect_back fallback_location: admin_skus_path, notice: "排序权重已更新。"
  end

  def show
  end

  def new
    category_id = params[:category_id]
    category = Category.find_by(id: category_id) if category_id.present?
    
    @sku = Sku.new(category: category)
  end

  def edit
  end

  def create
    begin
      filtered_params = sku_params
      # 提取图片位置信息，并从 filtered_params 中删除，防止 UnknownAttributeError
      image_positions = filtered_params.delete(:image_positions)
      
      # 过滤空的图片/文件占位符，防止保存时出现空附件
      # 注意：不要过滤 position 字段，因为 0.blank? 是 true
      # 提取图片/文件参数，用于后续单独处理，避免 Sku.new(params) 可能引起的自动分配
      images = filtered_params.delete(:images)

      @sku = Sku.new(filtered_params)
      if @sku.save
        # 显式使用 attach 附加图片/文件
        @sku.images.attach(images) if images.present?

        update_image_positions(@sku, image_positions)
        redirect_to sku_list_path, notice: "SKU created successfully."
      else
        Rails.logger.error "SKU Create Failed: #{@sku.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error "SKU Create Exception: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @sku ||= Sku.new
      @sku.errors.add(:base, "Save error: #{e.message}.")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    begin
      filtered_params = sku_params
      # 提取图片位置信息，并从 filtered_params 中删除，防止 UnknownAttributeError
      image_positions = filtered_params.delete(:image_positions)

      # 如果用户在编辑时没有上传新文件，从 params 中剔除对应键，防止覆盖旧文件
      # 注意：不要过滤 position 字段，因为 0.blank? 是 true
      # 注意：对于 images，如果使用了 config.active_storage.replace_on_assign_to_many = false
      # 那么上传新图片会附加到旧图片。如果上传的是空数组，则不进行任何操作。
      # 提取图片/文件参数，用于后续单独处理，避免 update 方法的全量替换行为
      images = filtered_params.delete(:images)

      if @sku.update(filtered_params)
        # 显式使用 attach 附加图片，确保不替换旧图片
        @sku.images.attach(images) if images.present?

        update_image_positions(@sku, image_positions)
        redirect_to sku_list_path, notice: "SKU updated successfully."
      else
        Rails.logger.error "SKU Update Failed: #{@sku.errors.full_messages.join(', ')}"
        render :edit, status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error "SKU Update Exception: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @sku ||= Sku.find(params[:id]) if params[:id]
      @sku.errors.add(:base, "Update error: #{e.message}.") if @sku
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sku.destroy
    redirect_to sku_list_path, notice: "SKU deleted successfully."
  end

  def delete_image
    return redirect_to sku_list_path, alert: "SKU not found." unless @sku
    
    image = @sku.images.find(params[:image_id])
    image.purge
    redirect_back fallback_location: edit_admin_sku_path(@sku), notice: "Image deleted successfully."
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: edit_admin_sku_path(@sku), alert: "Image not found."
  rescue ActiveStorage::InvariableError
    redirect_back fallback_location: edit_admin_sku_path(@sku), alert: "Invalid file format."
  end

  private

  def generate_csv(skus)
    CSV.generate(headers: true) do |csv|
      # 定义表头
      base_headers = ["ID", "Position", "Name", "Channel", "Category Path", "Price", "Status", "Image URLs"]
      battery_headers = [
        "Item", "Item No.", "Product Name", "Material", "Specification", 
        "Voltage", "Capacity", "Battery Cell", "Compatible Brands", 
        "Color/Appearance", "MOQ", "Sample Time", "Production Lead Time", "Packing", 
        "Carton Size", "Gross Weight"
      ]
      csv << base_headers + battery_headers + ["Standard Features HTML"]

      categories_cache = Category.all.includes(:parent).index_by(&:id)

      skus.each do |sku|
        cat = categories_cache[sku.category_id]
        path_segments = []
        while cat
          path_segments.unshift(cat.name)
          cat = categories_cache[cat.parent_id]
        end
        category_path = path_segments.join(" > ")

        image_urls = sku.images.attached? ? sku.images.map { |img| url_for(img) }.join(",") : ""
        
        row = [
          sku.id, sku.position, sku.name, sku.category.category_kind, category_path, sku.price, sku.status,
          image_urls
        ]
        
        battery_row = [
          sku.item, sku.item_no, sku.product_name, sku.material, sku.specification,
          sku.head_circumference, sku.brim_length, sku.closure_type, sku.embroidery_print,
          sku.color, sku.moq, sku.sample_time, sku.production_lead_time, sku.packing,
          sku.carton_size, sku.gross_weight
        ]
        
        csv << row + battery_row + [sku.standard_features.to_s]
      end
    end
  end

  def sku_list_path
    category_id = session[:sku_list_category_id]
    category_id.present? ? admin_skus_path(category_id: category_id) : admin_skus_path
  end

  def update_image_positions(sku, image_positions)
    return unless image_positions.present?

    valid_ids = sku.images_attachments.pluck(:id)
    image_positions.each do |id, pos|
      parsed_id = Integer(id) rescue nil
      next unless parsed_id && valid_ids.include?(parsed_id)
      parsed_pos = (Integer(pos) rescue 0).clamp(0, 999_999)
      ActiveStorage::Attachment.where(id: parsed_id).update_all(position: parsed_pos)
    end
  end

  def set_sku
    @sku = Sku.find(params[:id])
  end

  def sku_params
    params.require(:sku).permit(
      :name, :category_id, :price, :status, :position,
      :item, :item_no, :product_name, :material, :specification, :head_circumference,
      :brim_length, :closure_type, :embroidery_print, :color, :moq, :sample_time,
      :production_lead_time, :packing, :carton_size, :gross_weight,
      :standard_features,
      :meta_title, :meta_description, :meta_keywords,
      images: [], image_positions: {}
    )
  end
end
