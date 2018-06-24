import React from "react"
import PropTypes from "prop-types"

export default class PersonContact extends React.Component {

	constructor (props) {
    super(props)
    this.state = {
    	id: props.user_id,
    	name: props.name
    }
  }


  render () {
    return (
	    	<a href="#" data-id={this.state.id} data-toggle="modal" data-identifier={this.state.name} data-target="#timeSlotContactModal" className='btn btn-md btn-person btn-primary broadcast-message' end-pt='/holders/send_text'>{this.state.name}</a>
    );
  }
}
