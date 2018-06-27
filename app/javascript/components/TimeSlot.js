import React from "react"
import PropTypes from "prop-types"
import PersonContact from "./PersonContact"

export default class TimeSlot extends React.Component {

	constructor (props) {
    super(props);
    this.state = {
			expanded: false
    };

    // This binding is necessary to make `this` work in the callback
    this.expandBox = this.expandBox.bind(this);
  }

  expandBox() {
  	if (!this.state.expanded) {
	  	this.props.onChange();
  	}

		this.setState((prevState, props) => ({
				expanded: !prevState.expanded
		}));
  }


  closeBox(){
  	this.setState((prevState, props) => ({
				expanded: false
		}));

  }



  render () {
  	const time = this.props;
    return (
    	<div key={time.id}>
      	<a data-id={time.id} className='expand-slot btn btn-lg btn-primary time_slot centered' onClick={this.expandBox}>
					<b>
				     {time.time}:  
					</b>
					<span className="ppl_list">
					   __({time.people})__
					</span>
				</a>

				<div className="list-grp-detail" style={ this.state.expanded ? {display: "block"} : {display: "none"} } id={"info-" + time.id}>
					<div className="contact-list">
					<span id={"notes_for" + time.id}>
						{ time.notes }
					</span>
						<div className="verbose_list">
							<div>
								{time.people_hash.map(function(elem, idx) {
										return (
												<div key={"contact_" + idx}>
													<PersonContact user_id={elem.id} name={elem.name} />
									    	</div>
											)
								})}
							</div>

							<a href="#" className='broadcast-message btn-wide btn btn-lg btn-primary btn-contact-grp' data-id={time.id} end-pt='/line_day/time_slots/broadcast_to_slot' data-identifier={"Wait shift: " + time.time} data-toggle="modal" data-target="#timeSlotContactModal">Broadcast a message to this group</a>
						</div>
						{time.has_current ? 
								<form className="new_holder" id="new_holder" action="/holders/erase" acceptCharset="UTF-8"><input name="utf8" type="hidden" value="✓" /><input type="hidden" name="authenticity_token" value={time.authenticity_token} />

								  <div className="field form-group">
								    <input value={time.id} type="hidden" name="holder[line_day_time_slot_id]" id="holder_line_day_time_slot_id" />
								  </div>

								  <div className="actions">

								    <input type="submit" name="commit" value="Unassign youself" className="btn btn-md btn-wide btn-spec btn-primary" data-disable-with="un assigning You" />

								  </div>
								</form> 
							: 
							<form className="new_holder" id="new_holder" action="/holders" acceptCharset="UTF-8" method="post"><input name="utf8" type="hidden" value="✓" /><input type="hidden" name="authenticity_token" value={time.authenticity_token} />

							  <div className="field form-group">
							    <input value={time.id} type="hidden" name="holder[line_day_time_slot_id]" id="holder_line_day_time_slot_id" />
							  </div>

							  <div className="actions">

							    <input type="submit" name="commit" value="Sign up for this wait shift" className="btn btn-md btn-wide btn-spec btn-primary" data-disable-with="Assigning You" />

							  </div>
							</form>
						}
					</div>

					<div>
					<a href="#" data-id={time.id} end-pt={"/line_day/time_slots/" + time.id} data-toggle="modal" data-target="#timeSlotEdit" className='modal-pop edit-slot btn-wide centered btn btn-lg btn-warning'>Edit</a>
					{ this.props.is_admin ? 
							<a href={"/line_day/time_slots/" + time.id} data-id={time.id} className='modal-pop btn-wide delete-slot centered btn btn-lg btn-danger'>Delete</a>
						:
						<div></div>
					}
					</div>
				

				</div>
    	</div>
    );
  }
}

