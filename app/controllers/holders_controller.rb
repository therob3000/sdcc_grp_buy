require 'twilio-ruby'

class HoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_holder, only: [:show, :edit, :update, :destroy], except: [:erase]

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
    contact_id = contact_holder_params[:contact_id]
    slot_id = contact_holder_params[:slot_id]
    holder = Holder.where({:user_id => contact_id, :line_day_time_slot_id => slot_id}).first
    text = contact_holder_params[:body]
    # begin
      account_sid = ENV['TWILIO_ACCOUNT_SID']
      auth_token = ENV['TWILIO_AUTH_TOKEN']
      # number = number_to_phone(holder.user.phone, country_code: 1)
      number = holder.user.phone
      # raise 'No Phone number provided' if number.nil?
      # twilio API
      @client = Twilio::REST::Client.new account_sid, auth_token

      @client.api.account.messages.create(
        from: "+#{ENV['TWILIO_NUMBER']}",
        to: '+14152796392',
        body: text
      )
      # persist to holder text message record
      TextMessageRecord.create(:user_id => holder.user_id)
      respond_to do |format|
          format.html { redirect_to :back, notice: "Message sent to #{holder.user.name}." }
        end
    # rescue Exception => e
    #   respond_to do |format|
    #     format.html { redirect_to :back, notice: e.message }
    #   end
    # end
  end

  # GET /holders/1/edit
  def edit
  end

  def erase
    time_slot_id = holder_params[:line_day_time_slot_id]
    holder = Holder.find_by ({:line_day_time_slot_id => time_slot_id, :user_id => current_user.id})
    begin
      holder.destroy
      respond_to do |format|
        format.html { redirect_to :back, notice: 'you were successfully unassigned from group.' }
      end    
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, notice: e.message }
      end
    end
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
        format.html { redirect_to :back, notice: 'You were successfully assigned.' }
        format.json { render :show, status: :created, location: @holder }
      else
        format.html { redirect_to :back, notice: 'Could not assign you to this group again.' }
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
      format.html { redirect_to :back, notice: 'Holder was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_holder
      @holder = Holder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def holder_params
      params.require(:holder).permit(:line_day_time_slot_id, :contact_id)
    end

    def contact_holder_params
      params.require(:holder_contact).permit(:contact_id,:body,:slot_id)
    end

end
