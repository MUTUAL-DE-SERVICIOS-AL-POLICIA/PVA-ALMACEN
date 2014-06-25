class ArticlesController < ApplicationController
  load_and_authorize_resource
  before_action :set_article, only: [:show, :edit, :update, :change_status]

  # GET /articles
  def index
    format_to('articles', ArticlesDatatable)
  end

  # GET /articles/1
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /articles/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /articles
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to articles_url, notice: t('general.created', model: Article.model_name.human) }
      else
        format.html { render action: 'form' }
      end
    end
  end

  # PATCH/PUT /articles/1
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to articles_url, notice: t('general.updated', model: Article.model_name.human) }
      else
        format.html { render action: 'form' }
      end
    end
  end

  def change_status
    @article.change_status unless @article.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def article_params
      params.require(:article).permit(:code, :description, :status, :material_id)
    end
end