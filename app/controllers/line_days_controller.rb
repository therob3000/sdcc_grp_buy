class LineDaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_line_day, only: [:show, :edit, :update, :destroy]

  # GET /line_days
  # GET /line_days.json
  def index
    @line_days = LineDay.all
  end

  # GET /line_days/1
  # GET /line_days/1.json
  def show
    @time_slots = @line_day.time_slots
    @line_day_time_slot = LineDay::TimeSlot.new
  end

  # GET /line_days/new
  def new
    @line_day = LineDay.new
  end

  # GET /line_days/1/edit
  def edit
  end

  # POST /line_days
  # POST /line_days.json
  def create
    @line_day = LineDay.new(line_day_params)

    respond_to do |format|
      if @line_day.save
        format.html { redirect_to @line_day, notice: 'Line day was successfully created.' }
        format.json { render :show, status: :created, location: @line_day }
      else
        format.html { render :new }
        format.json { render json: @line_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /line_days/1
  # PATCH/PUT /line_days/1.json
  def update
    respond_to do |format|
      if @line_day.update(line_day_params)
        format.html { redirect_to @line_day, notice: 'Line day was successfully updated.' }
        format.json { render :show, status: :ok, location: @line_day }
      else
        format.html { render :edit }
        format.json { render json: @line_day.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /line_days/1
  # DELETE /line_days/1.json
  def destroy
    @line_day.destroy
    respond_to do |format|
      format.html { redirect_to line_days_url, notice: 'Line day was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line_day
      @line_day = LineDay.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def line_day_params
      params.require(:line_day).permit(:day, :description)
    end
end
