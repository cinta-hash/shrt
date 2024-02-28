class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_link, only: %i[show edit update destroy]
  before_action :load_user_links, only: [:index]

  def index
    @link = Link.new
  end

  def new
    @link = Link.new
  end

  def show
    redirect_to @link.long_url, allow_other_host: true
  end

  def create
    @link = current_user.links.build(link_params)
    @link.short_url = generate_short_url(link_params[:short_url])

    respond_to do |format|
      if @link.save
        format.html { redirect_to links_path, notice: 'Link was successfully created.' }
        format.json { render :show, status: :created, location: @link }
      else
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @link.update(link_params)
        format.html { redirect_to links_path, notice: 'Link was successfully updated.' }
        format.json { render :show, status: :ok, location: @link }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @link.destroy
    respond_to do |format|
      format.html { redirect_to links_url, notice: 'Link was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def redirect
    @link = Link.find_by_short_url(params[:short_url])

   if @link
    @link.increment!(:clicks)
    if valid_url?(@link.long_url)
      redirect_to @link.long_url
     else
      render json: { error: "Invalid URL for redirection" }, status: :unprocessable_entity
    end
   else
    render json: { error: "Short URL not found" }, status: :not_found
  end
  end

  private

  def set_link
    @link = current_user.links.find_by(id: params[:id])
    redirect_to root_path, alert: 'Link not found' unless @link
  end

  def valid_url?(url)
    url.present? && (url.starts_with?("http://") || url.starts_with?("https://"))
  end

  def load_user_links
    @links = current_user.links
  end

  def link_params
    params.require(:link).permit(:long_url, :short_url)
  end

  def generate_short_url(custom_url)
    return custom_url if custom_url.present? && !Link.exists?(short_url: custom_url)

    loop do
      short_url = SecureRandom.hex(4)
      return short_url unless Link.exists?(short_url: short_url)
    end
  end
end
