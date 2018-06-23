class HoldersController < ApplicationController
  before_action :set_holder, only: [:show, :edit, :update, :destroy]

  # GET /holders
  # GET /holders.json
  def index
    @holders = Holder.all
  end

  # GET /holders/1
  # GET /holders/1.json
  def show
  end

  # GET /holders/new
  def new
    @holder = Holder.new
  end

  def send_text
    
  end

  # GET /holders/1/edit
  def edit
  end

  # POST /holders
  # POST /holders.json
  def create
    @holder = Holder.new(holder_params)
    @holder.user_id = current_user.id
    @holder.email = current_user.email
    @holder.number = current_user.phone
    respond_to do |format|
      if @holder.save
        format.html { redirect_to :back, notice: 'Holder was successfully created.' }
        format.json { render :show, status: :created, location: @holder }
      else
        format.html { render :new }
        format.json { render json: @holder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /holders/1
  # PATCH/PUT /holders/1.json
  def update
    respond_to do |format|
      if @holder.update(holder_params)
        format.html { redirect_to @holder, notice: 'Holder was successfully updated.' }
        format.json { render :show, status: :ok, location: @holder }
      else
        format.html { render :edit }
        format.json { render json: @holder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /holders/1
  # DELETE /holders/1.json
  def destroy
    @holder.destroy
    respond_to do |format|
      format.html { redirect_to holders_url, notice: 'Holder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_holder
      @holder = Holder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def holder_params
      params.require(:holder).permit(:line_day_time_slot_id)
    end
end
