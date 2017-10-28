class PurchasesController < ApplicationController
	before_action :authenticate_user!,:validate

	include SecurityHelper

	def index
		if params[:page]
			@purchases = Purchase.paginate(:page => params[:page], :per_page => 5)		
		else
			@purchases = Purchase.paginate(:page => 1, :per_page => 5)		
		end
	end

	def search
		groups = Purchase.joins("JOIN members on purchases.member_id=members.id").where("lower(members.name) like ? OR lower(members.last_name) like ?", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%").first(5)
		render :partial => 'code_results_purchases', :locals => { :purs => groups }
	end

	def create
		member = Member.find(purchase_params['member_id'])
		mem_grp = MemberGroup.find(params[:member_group_id])
		member.covered = true;
		pur = Purchase.new(purchase_params)
		pur.user_id = current_user.id
		if purchase_params['member_id'].nil?
			# then it was the current user that purchased for them
			put.notes += "\n Purchased by #{current_user.name} Contact at #{current_user.email}"
		end

		if member.save && pur.save
			# SEND EMAIL TO THE USER
			purchasing_member_notes = ''
			if (purchase_params["covering_id"].nil?) || (purchase_params["covering_id"] == '')
				purchasing_member_notes = current_user.payment_info
				purchasing_member_first_name = current_user.name
				purchasing_member_name = "#{current_user.name} (#{current_user.email})"
				add_notes = current_user.payment_info
			else
				pur_mem = Member.find(purchase_params["covering_id"])
				purchasing_member_notes = pur_mem.payment_info
				purchasing_member_first_name = pur_mem.name
				purchasing_member_name = "#{pur_mem.name} #{pur_mem.last_name} (#{pur_mem.email}. #{ pur_mem.phone ? 'phone:' + pur_mem.phone : ''})"
				add_notes = pur_mem.payment_info
			end
 	
			# if the member still has some days needed then we make thier active status false
			if !member.full_covered
				member.active = false
				member.save
			end

      obj = {
        email: member.email, 
        member: member,
        purchase: purchase,
        purchasing_member_notes: purchasing_member_notes,
        purchasing_member_first_name: purchasing_member_first_name,
        purchasing_member_name: purchasing_member_name,
        add_notes: add_notes
      }

      # begin
	      MyMailer.send_confirmation(obj, "CONGRATULATIONS!  #{purchasing_member_first_name} has covered you for SDCC 2018!!").deliver
				# render out
				render :json => { :success => true, :member_group_id => mem_grp.id, :groups => member.member_groups.map { |e| e.group_id }.join('-'), :group_id => params[:group_id], :member_id => member.id, :message => 'purchased!' }
    #   rescue Exception => e
				# render :json => { :success => false, :member_group_id => mem_grp.id, :groups => member.member_groups.map { |e| e.group_id }.join('-'), :group_id => params[:group_id], :member_id => member.id, :message => 'Member was purchased for but the e-mail never went through, please check the user email, or contact this person yourself' }
    #   end

		else
			errs = []

			pur.errors.full_messages.each do |e|
				errs << e
			end

			member.errors.full_messages.each do |e|
				errs << e
			end
			render :json => { :success => false, :message => errs }
		end
	end

	def send_out_confirmation
		# find the purchase
		# Purchase(id: integer, user_id: integer, need_id: integer, created_at: datetime, updated_at: datetime, member_id: integer, confirmation_code: integer, covering_id: integer, price: float, notes: text, wensday: boolean, thursday: boolean, friday: boolean, saturday: boolean, sunday: boolean, in_progress: boolean)
		purchase = Purchase.find(params[:purchase_id])
		member = purchase.member
		purchasing_member_first_name = purchase.benefactor_name

		obj = {
        email: member.email, 
        member: member,
        purchase: purchase,
        purchasing_member_notes: purchase.notes,
        purchasing_member_first_name: purchase.benefactor_name,
        purchasing_member_name: purchase.benefactor_name,
        add_notes: ""
      }

		MyMailer.send_confirmation(obj, "CONGRATULATIONS!  #{purchasing_member_first_name} has covered you for SDCC 2018!!").deliver
		render :json => { :success => true, :purchase_id => purchase.id }
	end


	private 

	def purchase_params
		params.require(:conf).permit(:confirmation_code,:price,:covering_id,:notes,:member_id, :wensday, :thursday, :friday, :saturday, :sunday)
	end
end
