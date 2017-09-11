$(document).ready(function() {

	if (group_id == undefined) {
		return;
	}
  $('body').on('click', '.form-check-stacked', function(event) {
    var checkBox = $(this).find('input[type="checkbox"]');
    checkBox.trigger('click');

    if (checkBox.is(':checked')) {
      $(this).css('background-color','#fd7777');
      $(this).css('color','white');
    } else { 
      $(this).css('background-color','#ffcccc');
      $(this).css('color','black');
    }
  });
	$('body').on('submit', '#create-member-form', function(event) {
		event.preventDefault();
		// create the member.
		$.ajax({
			url: '/members/register_member',
			type: 'POST',
			data: $(this).serialize(),
		})
		.done(function(data) {
			if (data.success) {
				// register the member to the group.
				$('#new-member-form').slideUp(500);
				$('#create-member-form').trigger('reset');
				regMember($('#reg-member').serialize());
				$(this).trigger('reset');

			} else {
				populateErrors(data.message);
			}
		})		
	});
	$("body").on('click', '.cancel-this', function(event) {
		event.preventDefault();
		dispatcher.trigger('deactivate_member', { member_id: $(this).attr('member-id'), connection: connectionID });
		// switch out buttons
		$('.active-button-' + $(this).attr('member-id')).fadeOut(500, function() {
			$('.activate-button-for' + $(this).attr('member-id')).fadeIn(1000);
		});

		$(".member_groups_marker_" + $(this).attr('member-id')).removeClass('member_active');
	});
	$("body").on('click', '.confirm-this', function(event) {
		event.preventDefault();
		$.ajax({
			url: '/members/present_confirmation_partial',
			data: {member_id: $(this).attr('member-id'), mem_group_id: $(this).attr('data-id')},
		})
		.done(function(data) {
			$('#confirmation-body').html(data);
		})
	});

	$('body').on('click', '.smaller_member_item', function(event) {
		event.preventDefault();
		var mem_id = $(this).attr('data-id');
		$('input[name="conf[covering_id]"]').val(mem_id);
	});

	$('body').on('click', '.iam', function(event) {
		event.preventDefault();
		$('input[name="conf[covering_id]"').val('');
		updateCoveredName();
	});

	$('body').on('click', '.another', function(event) {
		event.preventDefault();
		$('#cover_member_box').slideDown(1000, function() {});
	});

	$('body').on('click', '.smaller_member_item', function(event) {
		event.preventDefault();
		var member_id = $(this).attr('data-id');
		$('input[name="conf[covering_id]"').val(member_id);
		updateCoveredName();
	});

	$('body').on('submit', '.member-coverage-form', function(event) {
		event.preventDefault();
		var data = $(this).serialize();

		$('.conf-modal-footer').fadeOut(500, function() {
			$('.working-message-conf').fadeIn(500);
		});

		$.ajax({
			url: $(this).attr('action'),
			type: 'POST',
			data: data,
		})
		.done(function(data) {
			if (data.success) {
				//  TODO:  broadcast message
				dispatcher.trigger('cover_member', { 
					member_id: data.member_id,
					member_group_id:data.member_group_id,
					group_id:data.group_id,
					groups:data.groups, 
					connection: connectionID
				});
				$('.member-coverage-form').trigger('reset');
				$('.close-this-modal').trigger('click');
				$('.working-message-conf').fadeOut(500, function() {
					$('.conf-modal-footer').fadeIn(500);
				});
			} else {
				$('.working-message-conf').fadeOut(500, function() {
					$('.conf-modal-footer').fadeIn(500);
				});
				alert(data.message)
			}
		})
	});

	$('body').on('click', '#confirm-trigger', function(event) {
		event.preventDefault();
		$('.member-coverage-form').trigger('submit');
	});

	function updateCoveredName(){
		var val = $('input[name="conf[covering_id]"').val();
		if (val == '') {
			$('#cover_name').html('<b>You</b> are Covering this user');
		} else {
			$.ajax({
				url: '/members/find_member_name',
				data: {id: val},
			})
			.done(function(data) {
				$('#cover_name').html('<b>' + data.name + '</b> will cover this member');
			})
		}
	}

  $('body').on('keyup', '#m_modal_search', function(event) {
    event.preventDefault();
    performSearchInModal();
  });

	function performSearchInModal(){
    var phrase = $("#m_modal_search").val();
    $.ajax({
      url: '/members/search_smaller',
      data: {search: phrase},
    })
    .done(function(data) {
      $('.member-list-results').html(data);
    })    
  }


	$("body").on('click', '.activate', function(event) {
		event.preventDefault();
		dispatcher.trigger('activate_member', { member_id: $(this).attr('member-id'), connection: connectionID});
		$(this).fadeOut(1000, function() {
			$(this).parent('').find('.active-button').fadeIn(1000);
		});

		$(".member_groups_marker_" + $(this).attr('member-id')).addClass('member_active');
	});


	$("body").on('submit', '#reg-member', function(event) {
		event.preventDefault();
		regMember($(this).serialize());
	});

	$("body").on('click', '.remove-this-user', function(event) {
		event.preventDefault();
		var mb_id = $(this).attr('data-id');
		removeMemberFromDom(mb_id);		
	});

	$('body').on('click', '.buy-ticket', function(event) {
		event.preventDefault();
		var mem_id = $(this).attr('data-id');
		var need_id = $(this).attr('need-id');
		var member_group_id = $(this).attr('member_group_id');
		
		coverMember(mem_id, need_id, member_group_id, group_id);
	});

	function regMember(dataSend){
		$.ajax({
			url: '/members/register_member_to_group',
			method: 'POST',
			data: dataSend,
		})
		.done(function(data) {
			if (data.success == true) {
				$("#reg-member").trigger('reset');
				var obj = {connection: connectionID, room: group_id, member_id: data.member_id, member_group_id: data.member_group_id}
				dispatcher.trigger('register_member', obj)
			} else {
				if (data.new_member) {
					$('#new-member-form').slideDown('500', function() {
						var sdcc_num = $('#sdcc_member_id_holder').val();
						$('#sdcc_member_id_holder_create').val(sdcc_num);
					});
				} else {
					populateErrors(data.message);
				}
			}
		})
	}

	var coverMember = function(member_id, need_id, member_group_id, group_id){
		$.ajax({
			url: '/members/cover_member',
			data: {member_id: member_id, need_id: need_id, member_group_id: member_group_id, group_id: group_id},
		})
		.done(function(data) {
			if (data.success) {
				var obj = {connection: connectionID, member_group_id: data.member_group_id, groups: data.groups, group_id: data.group_id};
				dispatcher.trigger('cover_member', obj);
			} else {
				populateErrors(data.message);
			}
		})
		
	}

  var removeMemberFromDom = function(member_group_id) {
    $.ajax({
    	url: '/members/remove_member',
    	method: 'DELETE',
    	data: {mem_grp_id: member_group_id, grp_id: group_id},
    })
    .done(function(data) {
    	if (data.success) {
			  	var obj = {connection: connectionID, room: group_id, member_group_id: data.message}
					dispatcher.trigger('unregister', obj)
    	}
    })
  }

  var addMemberToDom = function(message) {
    var member_group_id = message.member_group_id;
    $.ajax({
    	url: '/groups/present_member',
    	data: {mem_grp_id: member_group_id, grp_id: group_id},
    })
    .done(function(data) {
    	$("#member-list").append(data);
    })
  }

  var success = function(response) {
	  console.log("Wow it worked: ", response);
	}

	var failure = function(response) {
		  console.log("That just totally failed: ", response);
	}


	function startDispatch(){
	  dispatcher = new WebSocketRails(dispatcher_link);
	  dispatcher.on_open = function(data) {
	  	// sleep(1000);
	  	if (!activeDispatcher) {
	  		// return;
		    console.log('Connection has been established: ', data);
		    connectionID = data.connection_id;
		    connection = group_id;
		    group_room_conn = 'group_'+ connection;
		    channel = dispatcher.subscribe(group_room_conn);
		    var room_create_success = group_room_conn + '_created';
		    activeDispatcher = true;

		    // BINDING EVENTS

		    // listen for newly registered members
		    channel.bind("member_registered", function(mes) {
		    	// if (message.connection_id != connectionID) {
		    	// 	return;
		    	// }
		    	var number = mes.num_of_ppl;
		    	if (number == 1) {
			    	$(".number-of-members").text(number + ' Member in this buying group')
		    	} else if (number == 0) {
			    	$(".number-of-members").text('This buying group is empty')
		    	} else {
			    	$(".number-of-members").text(number + ' Members in this buying group')
		    	}
		    	addMemberToDom(mes);
		    });

		    // listen for any dropped members
		    channel.bind("unregister_member",function(mes) {
		    	// if (message.connection_id != connectionID) {
		    	// 	return;
		    	// }
		    	var number = mes.num_of_ppl;
		    	if (number == 1) {
			    	$(".number-of-members").text(number + ' Member in this buying group')
		    	} else if (number == 0) {
			    	$(".number-of-members").text('This buying group is empty')
		    	} else {
			    	$(".number-of-members").text(number + ' Members in this buying group')
		    	}
		    	$("#member_row_" + mes.member_group_id).fadeOut('500', function() {
				    $("#member_row_" + mes.member_group_id).remove();
		    	});;
		    })

		    // listen for any covered members across all groups in this group
		    channel.bind("member_covered",function(mes) {
			    $("#member_row_" + mes.member_group_id).addClass('member_covered');
			    $('.active-button-' + mes.member_id).hide(500);
			    $("#action-holder-for" + mes.member_group_id).html("This member has been covered");
		    })

		    // listen for active members
		    channel.bind("activate_member",function(mes) {
		    	if (mes.connection_id != connectionID) {
			    	$(".activate-button-for" + mes.member_id).fadeOut(1000, function() {
				    	$("#action-message-for" + mes.member_id).fadeIn(1000, function() {});
			    	});
				    $(".member_groups_marker_" + mes.member_id).addClass('member_active');
		    	}
		    })

		    channel.bind("deactivate_member",function(mes) {
		    	if (mes.connection_id != connectionID) {
			    	$("#action-message-for" + mes.member_id).fadeOut(1000, function() {
				    	$(".activate-button-for" + mes.member_id).fadeIn(1000, function() {});
			    	});
				    $(".member_groups_marker_" + mes.member_id).removeClass('member_active');
		    	}
		    })

		    // chatroom listener
		    channel.bind('add_room_message', function(message) {
		    	if ($('.chat-box').css('height') == "25px") {
			    	$('.chat-box').animate({'background-color':'#b2f581'}, 500);
			    	$('.expand-chat-log').animate({'background-color':'#b2f581'}, 500);
			    	$('.expand-chat-log').text("New Message, click here to expand chat");
		    	}
		    	console.log(message.connection_id);
		    	if (typeof message.connection_id != 'undefined' ) {
			    	addCommentToDom(message);
		    	}
		    });

		    // someone_typing
		    channel.bind('someone_typing', function(message) {
		    	someoneTyping();
		    });

	    console.log(room_create_success);
	  	}
	  }
	}

	setTimeout(function(){
	  startDispatch();
	}, 500);

  var someoneTyping = function(){
  	$('.someone_typing').css('display', 'block');
  	$('.someone_typing').fadeOut(2000, function() {
  		
  	});

  }


// chat rooom functionality
	// var elem = document.getElementById('chat_log');
	// var elem2 = document.getElementById('chat_container');
 //  elem.scrollTop = elem.scrollHeight;
 //  elem2.scrollTop = elem2.scrollHeight;

 $('body').on('keydown', '.chat-message-input', function(event) {
		if (event.which == 13) {
		 	event.preventDefault();
		 	var message = $(this).val();
		 	$(this).val('');
		 	$.ajax({
		 		url: '/groups/process_message',
		 		type: 'POST',
		 		data: {message: {message: message, group_id: group_id}},
		 	})
		 	.done(function(data) {
		 		if (data.success) {
			 		var obj = { message: data.message, room: group_id, user_id: data.user_id, connection: connectionID};
			 		dispatcher.trigger('send_chat_message', obj);
		 		} else {
		 			populateErrors(data.message);
		 		}
		 	})

		} else {
			// notify users that someone is typing
			dispatcher.trigger('someone_typing', {room: group_id}, success, failure);
		}
 });

 $('body').on('click', '#non-covered-toggle', function(event) {
 	event.preventDefault();
 	if ($('.member_covered').css('display') == 'none') {
	 	$('.member_covered').slideDown(500);
 	} else {
	 	$('.member_covered').slideUp(500);
 	}
 });

$('body').on('click', '.expand-chat-log', function(event) {
	event.preventDefault();
	if ($('.chat-box').css('height') == '500px') {
		$('.chat-box').animate({'height': '0px'}, 500);
	} else {
		$('.chat-box').animate({'height': '500px'}, 500);
		$('.chat-box').animate({'background-color':'#efeacc'}, 500)
  	$('.expand-chat-log').animate({'background-color':'#3c8dbc'}, 500)
  	$('.expand-chat-log').text("expand chat log");
	}
 
});

  var addCommentToDom = function(message) {
  	var message_id = message.message_id;
    // if (message.connection_id == connectionID) {
    	$.ajax({
    		url: '/groups/add_comment',
    		data: {message_id: message_id, from: 'dom'},
    	})
    	.done(function(data) {
	      $("#chat_log").prepend(data);
	      $(".chat-line").slideDown(500, function() {});
    	})
    	
    // }
    // elem.scrollTop = elem.scrollHeight;
    var elem = $('#chat_log');
    elem.scrollTop = 0;
    console.log('just received new message: ' + message);
  }
	
});