class LineDay::TimeSlotsController < ApplicationController
  before_action :set_line_day_time_slot, only: [:show, :edit, :update, :destroy]

  # GET /line_day/time_slots
  # GET /line_day/time_slots.json
  def index
    @line_day_time_slots = LineDay::TimeSlot.all
  end

  # GET /line_day/time_slots/1
  # GET /line_day/time_slots/1.json
  def show
  end

  # GET /line_day/time_slots/new
  def new
    @line_day_time_slot = LineDay::TimeSlot.new
  end

  # GET /line_day/time_slots/1/edit
  def edit
  end

  # POST /line_day/time_slots
  # POST /line_day/time_slots.json
  def create
    @line_day_time_slot = LineDay::TimeSlot.new(line_day_time_slot_params)

    respond_to do |format|
      if @line_day_time_slot.save
        format.html { redirect_to :back, notice: 'Time slot was successfully created.' }
        format.json { render :show, status: :created, location: @line_day_time_slot }
      else
        format.html { render :new }
        format.json { render json: @line_day_time_slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /line_day/time_slots/1
  # PATCH/PUT /line_day/time_slots/1.json
  def update
    # respond_to do |format|
    if @line_day_time_slot.update(line_day_time_slot_params)
      render :json => @line_day_time_slot
    else
      render :json => {}
    end
      # if @line_day_time_slot.update(line_day_time_slot_params)
      #   # format.html { redirect_to :back, notice: 'Time slot was successfully updated.' }
      #   # format.json { render @line_day_time_slot, status: :ok }
      # else
      #   format.html { render :edit }
      #   format.json { render json: @line_day_time_slot.errors, status: :unprocessable_entity }
      # end
    # end
  end

  # DELETE /line_day/time_slots/1
  # DELETE /line_day/time_slots/1.json
  def destroy
    @line_day_time_slot.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Time slot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line_day_time_slot
      @line_day_time_slot = LineDay::TimeSlot.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def line_day_time_slot_params
      params.require(:line_day_time_slot).permit(:day, :description, :time, :line_day_id, :end_time)
    end
end
