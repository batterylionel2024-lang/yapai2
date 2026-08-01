class Admin::PartnersController < Admin::BaseController
  before_action :set_partner, only: [:edit, :update, :destroy]

  def index
    @partners = Partner.all.order(created_at: :desc)
  end

  def new
    @partner = Partner.new
  end

  def create
    @partner = Partner.new(partner_params)
    if @partner.save
      redirect_to admin_partners_path, notice: 'Partner was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @partner.update(partner_params)
      redirect_to admin_partners_path, notice: 'Partner was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @partner.destroy
    redirect_to admin_partners_path, notice: 'Partner was successfully destroyed.'
  end

  private

  def set_partner
    @partner = Partner.find(params[:id])
  end

  def partner_params
    params.require(:partner).permit(:name, :logo)
  end
end
