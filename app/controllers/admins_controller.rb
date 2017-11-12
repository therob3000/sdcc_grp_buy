class AdminsController < ApplicationController
	require "csv"
	before_action :authenticate_user!, :validate_admin
	include SecurityHelper

	def members_index
		if params[:page]
			@members = Member.paginate(:page => params[:page], :per_page => 5)		
		else
			@members = Member.paginate(:page => 1, :per_page => 5)		
		end
	end

	def search_members
		members = Member.where("lower(sdcc_member_id) like ? OR lower(name) like ?", "%#{params[:search].downcase}%", "%#{params[:search].downcase}%").first(5)
		render :partial => 'code_results_members', :locals => { :members => members }
	end

	def delete_member
		member = Member.find(params[:id])
		if member.delete
			render :json => { :success => true, :message => 'member destroyed!', :delete_id => member.id }
		else
			render :json => { :success => false, :message => member.errors.full_messages.join(',') }
		end
	end

	def upload_csv
    myfile = params[:file]
		@rowarraydisp = CSV.read(myfile.path)
		keys = []
		messages = []
		@errors = []

		legend = {
			"CCID" => params[:sdcc_id],
			"LastName" => params[:lastname],
			"FirstName" => params[:firstname],
			"Email" => params[:email],
			"DaysNeeded" => params[:daysneeded],
			"DaysBought" => params[:daysbought],
			"BuyerEmail" => params[:buyeremail],
			"Notes" => params[:notes]
		}

		if params[:group_name]
			group_name = params[:group_name]
			new_group = Group.find_by_name(group_name)
			if new_group.nil? 
				new_group = Group.new({:user_id => current_user.id, :name => group_name})
				if new_group.save
					messages << "<li class='success-message'>Created Group: #{group_name}</li>"
				end
					messages << "<li class='error-message'>Failed to Create Group: #{group_name} #{new_group.errors.full_messages.join(',')}</li>"
			end
		else
			new_group = nil
		end

		total_rows = @rowarraydisp.length		 	
		@rowarraydisp.each_with_index do |row,idx|
			next if idx < 3
			next if idx == 4
			if idx == 3
				keys = row	
			else			
				obj = {}
				row.each_with_index do |r,number|
					obj[keys[number]] = r
				end
				# map variables
				cci_id = obj[legend["CCID"]]

				next if cci_id.nil?

				needed_days = obj[legend["DaysNeeded"]]
				cc_email = obj[legend["Email"]]

				member_first_name = obj[legend["FirstName"]] 

				if member_first_name.nil?
					member_first_name = obj[legend["LastName"]]
				end

				member_last_name = obj[legend["LastName"]]
				days_bought_for_member = obj[legend["DaysBought"]]
				days_bought_for_email = obj[legend["BuyerEmail"]]
				these_notes = obj[legend["Notes"]]

				# create the member
				# TODO: map to what days needed
				days_needed = {
					:wensday => false,
					:thursday => false,
					:friday => false,
					:saturday => false,
					:sunday => false
				}

				# mapping: what does the 

				if needed_days.downcase.sub(" ","") == '4day+pn'
					days_needed = {
						:wensday => true,
						:thursday => true,
						:friday => true,
						:saturday => true,
						:sunday => true
					}
				else
					needed_days.split('+').each do |dayi|
						day = dayi.sub(" ","")
						if day.downcase == 'wen' || day.downcase == 'wens' || day.downcase == 'wensday'
							days_needed[:wensday] = true
						elsif day.downcase == 'thur' || day.downcase == 'thurs' || day.downcase == 'thursday'
							days_needed[:thursday] = true
						elsif day.downcase == 'fri' || day.downcase == 'friday' 
							days_needed[:friday] = true
						elsif day.downcase == 'sat' || day.downcase == 'saturday' 
							days_needed[:saturday] = true
						elsif day.downcase == 'sun' || day.downcase == 'sunday'
							days_needed[:sunday] = true
						end
					end
				end

				creation_obj = {
					:user_id => current_user.id,
					:sdcc_member_id => cci_id,
					:email => cc_email,
					:name => member_first_name, 
					:last_name => member_last_name, 
					:wensday => days_needed[:wensday], 
					:thursday => days_needed[:thursday], 
					:friday => days_needed[:friday], 
					:saturday => days_needed[:saturday], 
					:sunday => days_needed[:sunday]
				}

				edit_obj = {
					:sdcc_member_id => cci_id,
					:email => cc_email,
					:name => member_first_name, 
					:last_name => member_last_name
				}

				mem = Member.find_by_sdcc_member_id(cci_id)

				if mem
					already_in = true
					mem.assign_attributes(edit_obj)
				else
					already_in = false
					mem = Member.new(creation_obj)
				end

				# if there is a 'Days Bought' and 'Buyer Email'
				if !params[:first].nil? && !Purchase.exists?(:member_id => mem.id)
					if (!days_bought_for_member.nil? && days_bought_for_member != '') || (!days_bought_for_email.nil? && days_bought_for_email != '')
						# make a purchase (if one doesnt exists)
						obj2 = {
							'Days Bought' => days_bought_for_member,
							'Buyer Email' => days_bought_for_email,
							'Email' => cc_email,
							'Notes' => these_notes,
						}
						purchase = make_purchase(obj2,cci_id)
							if purchase.save
								if params[:send_email] && !email_opt_out(mem.email)
									if Rails.env.development?
										purchase.send_out_confirmation(current_user,'dev')
									else
										purchase.send_out_confirmation(current_user, 'prod')
									end
								end
								messages << "<li class='success-message'>#{obj['Buyer Email']} created purchase for #{cci_id}</li>"
							else
								messages << "<li class='error-message'>#{cci_id}: #{purchase.errors.full_messages.join(',')}</li>"
							end
					end
				end

				if mem.save
					
					if already_in
						messages << "<li class='success-message'>Updated member: #{cci_id}</li>"
					else
						messages << "<li class='success-message'>Created member: #{cci_id}</li>"
					end

					# TODO: if the member isn't already in new_group, than make a new MemberGroup
				else
					messages << "<li class='error-message'>#{cci_id}: #{mem.errors.full_messages.join(',')}</li>"
				end
			end
		end

		render :json => { :success => true, :messages => messages.join(', ') }
	end

	def email_opt_out(email)
		list = Email.opted_out_emails
		list.include?(email)
	end


	def make_purchase(obj,cci_id)
		days_bought = {
			:wensday => false,
			:thursday => false,
			:friday => false,
			:saturday => false,
			:sunday => false
		}

		warning = ""

		if obj['Days Bought']
			if obj['Days Bought'].downcase.sub(" ","") == '4day+pn'
				days_bought = {
					:wensday => true,
					:thursday => true,
					:friday => true,
					:saturday => true,
					:sunday => true
				}	
			elsif obj['Days Bought'].downcase.sub(" ","") == 'pn'
				days_bought = {
					:wensday => true,
					:thursday => false,
					:friday => false,
					:saturday => false,
					:sunday => false
				}	
			elsif obj['Days Bought'].downcase.sub(" ","") == '4day'
				days_bought = {
					:wensday => false,
					:thursday => true,
					:friday => true,
					:saturday => true,
					:sunday => true
				}	
			elsif obj['Days Bought'].downcase.sub(" ","") == 'thursdayonly'
				days_bought = {
					:wensday => false,
					:thursday => true,
					:friday => false,
					:saturday => false,
					:sunday => false
				}
			elsif obj['Days Bought'].downcase.sub(" ","") == 'fridayonly'
				days_bought = {
					:wensday => false,
					:thursday => false,
					:friday => true,
					:saturday => false,
					:sunday => false
				}
			elsif obj['Days Bought'].downcase.sub(" ","") == 'saturdayonly'
				days_bought = {
					:wensday => false,
					:thursday => false,
					:friday => false,
					:saturday => true,
					:sunday => false
				}
			elsif obj['Days Bought'].downcase.sub(" ","") == 'sundayonly'
				days_bought = {
					:wensday => false,
					:thursday => false,
					:friday => false,
					:saturday => false,
					:sunday => true
				}
			else
				obj['Days Bought'].split('+').each do |dayi|
					day = dayi.sub(" ","")
					if day.downcase == 'wen' || day.downcase == 'wens' || day.downcase == 'wensday'
						days_bought[:wensday] = true
					elsif day.downcase == 'thur' || day.downcase == 'thurs' || day.downcase == 'thursday'
						days_bought[:thursday] = true
					elsif day.downcase == 'fri' || day.downcase == 'friday' 
						days_bought[:friday] = true
					elsif day.downcase == 'sat' || day.downcase == 'saturday' 
						days_bought[:saturday] = true
					elsif day.downcase == 'sun' || day.downcase == 'sunday'
						days_bought[:sunday] = true
					end
				end
			end
		else
			warning = "This buyer did not specify what days were bought."
		end

		# find the covering member or user
		buyer_email = obj['Buyer Email']
		email = obj['Email']
		covering_member = Member.find_by_email(buyer_email)

		this_member = Member.find_by_sdcc_member_id(cci_id)

		purchase_params = {
			user_id: current_user.try(:id), 
			member_id: this_member.try(:id), 
			confirmation_code: nil, 
			covering_id: covering_member.try(:id),
			buyer_email: buyer_email,
			price: calc_price(obj['Days Bought']), 
			notes: "#{warning}  #{obj['Notes']}", 
			wensday: days_bought[:wensday], 
			thursday: days_bought[:thursday], 
			friday: days_bought[:friday], 
			saturday: days_bought[:saturday], 
			sunday: days_bought[:sunday], 
		}

		return Purchase.new(purchase_params)
	end

	def calc_price(days)
		return 0.00 if days.nil?
		
		pricing = {
			:wensday => 45.00,
			:thursday => 63.00,
			:friday => 63.00,
			:saturday => 63.00,
			:sunday => 42.00
		}

		days_bought = {
			:wensday => false,
			:thursday => false,
			:friday => false,
			:saturday => false,
			:sunday => false
		}


		if days.downcase.sub(" ","") == '4day+pn'
			days_bought = {
				:wensday => true,
				:thursday => true,
				:friday => true,
				:saturday => true,
				:sunday => true
			}	
		elsif days.downcase.sub(" ","") == 'pn'
			days_bought = {
				:wensday => true,
				:thursday => false,
				:friday => false,
				:saturday => false,
				:sunday => false
			}	
		elsif days.downcase.sub(" ","") == '4day'
			days_bought = {
				:wensday => false,
				:thursday => true,
				:friday => true,
				:saturday => true,
				:sunday => true
			}	
		elsif days.downcase.sub(" ","") == 'thursdayonly'
			days_bought = {
				:wensday => false,
				:thursday => true,
				:friday => false,
				:saturday => false,
				:sunday => false
			}
		elsif days.downcase.sub(" ","") == 'fridayonly'
			days_bought = {
				:wensday => false,
				:thursday => false,
				:friday => true,
				:saturday => false,
				:sunday => false
			}
		elsif days.downcase.sub(" ","") == 'saturdayonly'
			days_bought = {
				:wensday => false,
				:thursday => false,
				:friday => false,
				:saturday => true,
				:sunday => false
			}
		elsif days.downcase.sub(" ","") == 'sundayonly'
			days_bought = {
				:wensday => false,
				:thursday => false,
				:friday => false,
				:saturday => false,
				:sunday => true
			}
		else
			days.split('+').each do |dayi|
				day = dayi.sub(" ","")
				if day.downcase == 'wen' || day.downcase == 'wens' || day.downcase == 'wensday'
					days_bought[:wensday] = true
				elsif day.downcase == 'thur' || day.downcase == 'thurs' || day.downcase == 'thursday'
					days_bought[:thursday] = true
				elsif day.downcase == 'fri' || day.downcase == 'friday' 
					days_bought[:friday] = true
				elsif day.downcase == 'sat' || day.downcase == 'saturday' 
					days_bought[:saturday] = true
				elsif day.downcase == 'sun' || day.downcase == 'sunday'
					days_bought[:sunday] = true
				end
			end
		end

		total = 5.00

		days_bought.each do |key,value|
			if value
				total += pricing[key]
			end
		end

		total
	end

	def groups_index
		if params[:page]
			@groups = Group.paginate(:page => params[:page], :per_page => 5)		
		else
			@groups = Group.paginate(:page => 1, :per_page => 5)		
		end
		
	end

	def search_groups
		groups = Group.where("lower(name) like ?", "%#{params[:search].downcase}%").first(5)
		render :partial => 'code_results_groups', :locals => { :groups => groups }
	end

	def blow_up_group
		group = Group.find(params[:id])
		if group.delete
			render :json => { :success => true, :message => 'group destroyed!', :delete_id => group.id }
		else
			render :json => { :success => false, :message =>group.errors.full_messages.join(',') }
		end
	end

	def index
		if params[:page]
			@codes = ValidationCode.paginate(:page => params[:page], :per_page => 5)		
		else
			@codes = ValidationCode.paginate(:page => 1, :per_page => 5)		
		end
	end

	def search
		codes = ValidationCode.where("lower(email) like ?", "%#{params[:search].downcase}%").first(5)
		render :partial => 'code_results', :locals => { :codes => codes }
	end

	def users_index
		if params[:page]
			@users = User.paginate(:page => params[:page], :per_page => 5)		
		else
			@users = User.paginate(:page => 1, :per_page => 5)		
		end
	end

	def promote
		user = User.find(params[:id])
		user.is_admin = true
		if user.save
			render :json => { :success => true, :message => 'user promoted!', :admin_id => user.id }
		else
			render :json => { :success => false, :message =>user.errors.full_messages.join(',') }
		end	
	end

	def demote
		user = User.find(params[:id])
		user.is_admin = false
		if user.save
			render :json => { :success => true, :message => 'user promoted!', :admin_id => user.id }
		else
			render :json => { :success => false, :message =>user.errors.full_messages.join(',') }
		end	
	end

	def banish
		user = User.find(params[:id])
		if user.delete
			render :json => { :success => true, :message => 'user banished!', :delete_id => user.id }
		else
			render :json => { :success => false, :message =>user.errors.full_messages.join(',') }
		end
	end

	def search_users
		users = User.where("lower(name) like ?", "%#{params[:search].downcase}%").first(5)
		render :partial => 'code_results_users', :locals => { :users => users }
	end

	def create
		val_code = ValidationCode.new(code_params)
		code = gen_code
		val_code.code = code
		if val_code.save
			flash[:update] = 'saved'
		else
			flash[:error] = val_code.errors.full_messages.join(',')
		end

		redirect_to :back
	end

	def update
		# resets the code
		val_code = ValidationCode.find(params[:id])
		code = gen_code
		val_code.code = code
		if val_code.save
			render :json => { :success => true, :message => "code reset for #{val_code.email}", :code => code, :id => val_code.id }
		else
			render :json => { :success => false, :message =>val_code.errors.full_messages.join(',') }
		end
	end

	def send_email
		# sends the code
		val_code = ValidationCode.find(params[:id])
		email = val_code.email
		code = ''

		obj = {
			email: email, 
			message: "your validation code is: #{encrypt_code(val_code.code)}"
		}

		send_email_to_email(obj)

		if val_code.save
			render :json => { :success => true, :message => "email sent to #{email}", :code => code, :id => val_code.id }
		else
			render :json => { :success => false, :message =>val_code.errors.full_messages.join(',') }
		end
	end

	def send_email_to_email(obj)
		MyMailer.send_email(obj).deliver
	  # redirect_to root_url, notice: "Email sent!"
	end

	def destroy
		# deletes the code
		val_code = ValidationCode.find(params[:id])
		code = ''
		if val_code.delete
			render :json => { :success => true, :message => 'deleted', :code => code, :delete_id => val_code.id }
		else
			render :json => { :success => false, :message =>val_code.errors.full_messages.join(',') }
		end
	end


	private

	def code_params
		params.require(:code).permit(:email)
	end

	def validate_admin
		if !current_user.is_admin?
			redirect_to root_path
		end
	end
end
