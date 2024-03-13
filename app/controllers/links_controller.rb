class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_link, only: %i[show edit update destroy]
  before_action :load_user_links, only: [:index]

  def index
    @links = current_user.links
    @link = Link.new
  end

  def new
    @link = Link.new
  end

  def show
    redirect_to @link.long_url, allow_other_host: true
  end

  def create
    if current_user.nil?
      flash[:error] = "Please log in to create a link."
      redirect_to new_user_session_path
      return
    end
    
    @link = current_user.links.build(link_params)

    if link_params[:custom_url].present?
      @link.short_url = link_params[:custom_url]
    else
      @link.short_url = generate_short_url
    end

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
    if @link.update(link_params)
      redirect_to links_path, notice: 'Link was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @link.destroy
    redirect_to links_url, notice: 'Link was successfully destroyed.'
  end

  def redirect
    @link = Link.find_by_short_url(params[:short_url])

    if @link
      @link.increment!(:clicks)
      if valid_url?(@link.long_url)
        redirect_to @link.long_url
      else
        redirect_to root_path, alert: 'Invalid URL for redirection'
      end
    else
      redirect_to root_path, alert: 'Short URL not found'
    end
  end

  private

  def set_link
    @link = current_user.links.find_by(id: params[:id])
    redirect_to root_path, alert: 'Link not found' unless @link
  end

  def load_user_links
    @links = current_user.links
  end

  def link_params
    params.require(:link).permit(:long_url, :custom_url, :short_url)
  end

  def generate_short_url
    loop do
      short_url = SecureRandom.hex(4)
      return short_url unless Link.exists?(short_url: short_url)
    end
  end

  def valid_url?(url)
    url.present? && (url.starts_with?('http://') || url.starts_with?('https://'))
  end
end
