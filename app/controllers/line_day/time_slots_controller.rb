class LineDay::TimeSlotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_line_day_time_slot, only: [:show, :edit, :update, :destroy]

  include HoldersHelper
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

  def broadcast_to_slot
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']

    @slot = LineDay::TimeSlot.find(contact_holder_params[:contact_id])
    text = "MESSAGE FROM LINE WAIT GROUP (#{@slot.day}):  " + contact_holder_params[:body]
    messages = []
    @slot.holders.each do |holder|
      begin
        send_to_holder(holder,text)
        # messages << "message sent to #{holder.user.name}"
      rescue Exception => e
        messages << e.message
      end
    end

    respond_to do |format|
        format.html { redirect_to :back, notice: messages.join(', ') }
     end
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

    def contact_holder_params
      params.require(:holder_contact).permit(:contact_id,:body,:slot_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def line_day_time_slot_params
      params.require(:line_day_time_slot).permit(:day, :description, :time, :line_day_id, :end_time)
    end
end
