class SubarticlesController < ApplicationController
  load_and_authorize_resource
  before_action :set_subarticle, only: [:show, :edit, :update, :destroy, :change_status]

  # GET /subarticles
  def index
    format_to('subarticles', SubarticlesDatatable)
  end

  # GET /subarticles/1
  def show
  end

  # GET /subarticles/new
  def new
    @subarticle = Subarticle.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /subarticles/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /subarticles
  def create
    @subarticle = Subarticle.new(subarticle_params)

    respond_to do |format|
      if @subarticle.save
        format.html { redirect_to subarticles_url, notice: t('general.created', model: Subarticle.model_name.human) }
      else
        format.html { render action: 'form' }
      end
    end
  end

  # PATCH/PUT /subarticles/1
  def update
    respond_to do |format|
      if @subarticle.update(subarticle_params)
        format.html { redirect_to subarticles_url, notice: t('general.updated', model: Subarticle.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
      end
    end
  end

  def change_status
    @subarticle.change_status unless @subarticle.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def articles
    render json: Article.search_by(params[:material])
  end

  def get_subarticles
    render json: Subarticle.search_subarticle(params[:q])
  end

  def verify_amount
    render json: @subarticle.verify_amount(params[:amount])
  end

  def recode
    render "assets/recode"
  end

  def autocomplete
    subarticles = view_context.search_asset_subarticle(Subarticle, params[:q])
    respond_to do |format|
      format.json { render json: view_context.subarticles_json(subarticles) }
    end
  end

  def entry
    @entry_subarticle = EntrySubarticle.new
  end

  def entry_create
    @entry_subarticle = EntrySubarticle.new(entry_subarticle_params)

    if @entry_subarticle.save
      redirect_to @subarticle, notice: t('general.created', model: EntrySubarticle.model_name.human)
    else
      render action: 'entry'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subarticle
      @subarticle = Subarticle.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def subarticle_params
      params.require(:subarticle).permit(:code, :description, :unit, :status, :article_id, :amount, :minimum, :barcode)
    end

    def entry_subarticle_params
      params.require(:entry_subarticle).permit(:amount, :unit_cost, :total_cost, :invoice, :date, :subarticle_id)
    end
end
