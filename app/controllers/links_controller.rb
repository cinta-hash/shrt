class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_link, only: %i[show edit update destroy]
  before_action :update_clicks, only: [:show]
  

  def index
    @links = current_user ? current_user.links : []
  end

  def show
    @link = current_user.links.find(params[:id])
    @click_stats = @link.click_stats
    redirect_to @link.long_url, allow_other_host: true
  end

  def new
    @link = Link.new
  end

  def edit
  end

  def create
    if current_user.nil?
      flash[:error] = "Please log in to create a link."
      redirect_to new_user_session_path
      return
    end
    
    @link = current_user.links.build(link_params)

    respond_to do |format|
      if @link.save
        format.html { redirect_to link_url(@link), notice: 'Link was successfully created.' }
        format.json { render :show, status: :created, location: @link }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @link.update(link_params)
        format.html { redirect_to link_url(@link), notice: 'Link was successfully updated.' }
        format.json { render :show, status: :ok, location: @link }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @link.destroy!

    respond_to do |format|
      format.html { redirect_to links_url, notice: 'Link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def redirect_to_short_url
    @link = Link.find_by_short_url(params[:id])
    
    if @link
      @link.increment!(:clicks) # Increment the clicks count
      redirect_to @link.long_url, allow_other_host: true
    else
      render json: { error: "Short URL not found" }, status: :not_found
    end
  end

  private

  def set_link
    @link = current_user.links.find_by(id: params[:id])
    unless @link
      flash[:error] = "Link not found"
      redirect_to root_path
    end
  end

  def link_params
    params.require(:link).permit(:long_url)
  end

  def update_clicks
    return unless @link 

    @link.increment!(:clicks)
  end
end
