class Admin::SiteConfigsController < Admin::BaseController
  before_action :require_super_admin
  before_action :set_site_config

  def edit
  end

  def update
    if @site_config.update(site_config_params)
      redirect_to edit_admin_site_config_path, notice: "系统设置已更新。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_site_config
    @site_config = SiteConfig.get
  end

  def site_config_params
    params.require(:site_config).permit(
      :name, :meta_title, :meta_keywords, :meta_description,
      :phone, :email, :address, :copyright_year, :statistics_code,
      :logo, :favicon, :sitemap, :robots
    )
  end
end
