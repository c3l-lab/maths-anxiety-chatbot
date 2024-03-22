// splash_screen.js
$(document).ready(function() {
    $('#startTestButton').click(function() {
        // Use the data-participant-id attribute to get the participant ID
        var participantId = $(this).data('participant-id');

        $.ajax({
            url: '/start-chatbot/', // URL to your start_chatbot view
            type: 'POST',
            data: {
                'participant_id': participantId,
                'csrfmiddlewaretoken': $('input[name=csrfmiddlewaretoken]').val() // Add CSRF token
            },
            success: function(data) {
                // Hide the splash screen and proceed with starting the chatbot
                // Redirect, update the UI, or show a message as needed
            },
            error: function(xhr, status, error) {
                // Handle any errors
                console.error("Error starting the chatbot: ", error);
            }
        });
    });
});
